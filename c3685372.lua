--CX ギミック・パペット－ファナティクス・マキナ
-- 效果：
-- 9星怪兽×3
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「人偶」陷阱卡加入手卡。
-- ②：把这张卡1个超量素材取除才能发动。从自己或对方的墓地把1只怪兽在对方场上守备表示特殊召唤。
-- ③：对方场上有怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力一半数值的伤害。
local s,id,o=GetID()
-- 初始化函数：给卡片注册超量召唤手续（9星怪兽×3）以及①②③三个效果——①特殊召唤成功时检索「人偶」陷阱卡、②取除1个超量素材从双方墓地特召怪兽到对方场上、③对方场上有怪兽特殊召唤时破坏其中1只并给予伤害；三个效果均设为1回合各能使用1次。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以等级9的任意怪兽3只为素材进行超量召唤（对应效果文本“9星怪兽×3”）。
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「人偶」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。从自己或对方的墓地把1只怪兽在对方场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选双方墓地的怪兽在对方场上特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 为这张卡注册一个合并的延迟事件监听：将“怪兽特殊召唤成功”事件合并成自定义事件码custom_code，使③效果能被对方场上有怪兽特殊召唤的时点触发，同时避免同一连锁中对方特殊召唤多只怪兽时③效果重复发动。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ③：对方场上有怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力一半数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"伤害"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+2*o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 定义①效果检索用的过滤器：筛选持有「人偶」字段、类型为陷阱卡且能够加入手卡的卡片。
function s.thfilter(c)
	return c:IsSetCard(0x83) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的目标函数：发动时先从自己卡组检查是否存在符合条件的「人偶」陷阱卡；若存在，则登记操作信息为“从卡组将1张卡加入手卡”。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己的卡组中是否存在至少1张满足检索条件的「人偶」陷阱卡（chk==0时进行此判定）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将从卡组把1张卡加入手卡（CATEGORY_TOHAND），供其他卡与效果进行互动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张符合条件的「人偶」陷阱卡加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中筛选并选择1张满足“人偶”陷阱卡条件的卡，作为要加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「人偶」陷阱卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚刚加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的代价函数：检查并取除这张卡的1个超量素材（作为发动代价）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义②效果特殊召唤用过滤器：筛选墓地中能够被当前效果特殊召唤到对方（1-tp）场上、且为表侧守备表示的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- ②效果的目标函数：先检查发动条件——对方主要怪兽区有空位，且自己或对方墓地中存在满足特召条件的怪兽；条件通过后才会登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：对方场上存在可用的主要怪兽区空格（用于把怪兽特殊召唤到对方场上）。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 并且自己或对方墓地中至少存在1只符合特殊召唤条件的怪兽（由s.spfilter判断）；两个条件同时满足时②效果才能发动。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向对方玩家显示本效果的描述文本，提示对方你发动了②效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记操作信息：本次效果涉及从墓地特殊召唤1只怪兽，目标持有者为双方玩家（PLAYER_ALL），位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- ②效果的处理：如果对方场上仍有可用区域，则从双方墓地选择1只怪兽，以表侧守备表示特殊召唤到对方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：若对方场上已没有可用的主要怪兽区，则直接结束处理，不进行特殊召唤。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)==0 then return end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地选择1只同时满足特召条件且不受王家长眠之谷影响的怪兽（用NecroValleyFilter排除墓地效果被无效的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到对方（1-tp）的场上。
		Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 定义③效果的可选目标过滤器：筛选位于场上、控制者为对方、且能够成为当前效果对象的怪兽。
function s.desfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsCanBeEffectTarget(e)
end
-- ③效果的发动条件：事件组eg中存在至少1只由对方控制的怪兽，即对方场上有怪兽被特殊召唤。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- ③效果的目标函数：从对方本次特殊召唤成功的怪兽中选出1只作为对象（只有1只时自动指定，多只时弹窗选择），并登记破坏信息；若该对象表侧表示且原本攻击力大于0，则同时登记给对方造成伤害的信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=eg:Filter(s.desfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 将选中的怪兽设为当前连锁的目标卡，使其与③效果建立取对象关系。
		Duel.SetTargetCard(sg)
	else
		-- 显示选择提示：请选择要破坏的卡。
		Duel.Hint(HINTMSG_DESTROY,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上刚刚特殊召唤成功的怪兽组g中选择1只作为③效果的对象，同时登记为当前连锁的取对象目标。
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 登记操作信息：本次效果将破坏所选对象（1张怪兽卡）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
	if sg:GetFirst():IsFaceup() and math.max(0,sg:GetFirst():GetTextAttack())>0 then
		-- 登记操作信息：若对象原本攻击力大于0，本次效果将对对方玩家造成伤害（具体伤害值在效果处理时计算）。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- ③效果的处理：取回对象怪兽；若它仍与③效果关联且是怪兽，则将其破坏；破坏成功且其原本攻击力大于0时，给予对方原本攻击力一半数值的伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果发动时选择的目标怪兽（当前连锁的第一个对象）。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽仍与③效果关联且仍为怪兽，然后以效果将其破坏；若破坏成功（返回值非0）才继续处理后续伤害。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=math.max(0,tc:GetTextAttack())
		if atk>0 then
			-- 给予对方玩家对象怪兽原本攻击力一半数值（向下取整）的伤害，原因为效果伤害。
			Duel.Damage(1-tp,math.floor(atk/2),REASON_EFFECT)
		end
	end
end
