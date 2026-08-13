--ヴァンパイア・グレイス
-- 效果：
-- 这张卡在墓地存在，不死族怪兽的效果让自己场上有5星以上的不死族怪兽特殊召唤时，支付2000基本分才能发动。这张卡从墓地特殊召唤。「吸血鬼·格蕾丝」的这个效果1回合只能使用1次。此外，1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方把宣言的种类的1张卡从卡组送去墓地。
function c40607210.initial_effect(c)
	-- 这张卡在墓地存在，不死族怪兽的效果让自己场上有5星以上的不死族怪兽特殊召唤时，支付2000基本分才能发动。这张卡从墓地特殊召唤。「吸血鬼·格蕾丝」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40607210,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,40607210)
	e1:SetCondition(c40607210.condition)
	e1:SetCost(c40607210.cost)
	e1:SetTarget(c40607210.target)
	e1:SetOperation(c40607210.operation)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，宣言卡的种类（怪兽·魔法·陷阱）才能发动。对方把宣言的种类的1张卡从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40607210,1))  --"卡组送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c40607210.tgtg)
	e2:SetOperation(c40607210.tgop)
	c:RegisterEffect(e2)
end
-- 筛选函数：判断特殊召唤成功的怪兽是否为满足条件的5星以上不死族怪兽，要求其等级≥5、种族为不死族、控制者为发动方，且特殊召唤信息中的类型含怪兽、种族含不死族。
function c40607210.cfilter(c,tp)
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE) and c:IsControler(tp)
		and typ&TYPE_MONSTER~=0 and race&RACE_ZOMBIE~=0
end
-- 诱发条件：检查本次特殊召唤成功的怪兽组中是否存在至少1只满足上述筛选条件的怪兽（即我方场上有5星以上不死族怪兽被特殊召唤）。
function c40607210.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c40607210.cfilter,1,nil,tp)
end
-- 代价函数：本效果发动需要支付2000基本分，这里进行支付判定并实际扣除。
function c40607210.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：在效果发动前检查玩家是否能够支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际支付2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- 目标函数：进行效果发动的合法检查，要求我方主要怪兽区有空位，且墓地的这张卡可以被特殊召唤。
function c40607210.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将特殊召唤这张卡（数量1），供其他效果或时点进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到我方场上。
function c40607210.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡特殊召唤到其持有者（发动玩家）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 起动效果的目标处理：本效果没有发动条件；发动时需要宣言一个卡片种类并记录在label中，同时设置从对方卡组送墓1张卡的操作信息。
function c40607210.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向发动玩家发送选择卡片种类的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 由发动玩家宣言一个卡片种类（怪兽/魔法/陷阱），返回值存储到op。
	local op=Duel.AnnounceType(tp)
	e:SetLabel(op)
	-- 设置操作信息：将从对方卡组把1张卡送去墓地（不取对象，具体种类由宣言决定）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 筛选函数：用于从对方卡组中选出指定种类且能够送去墓地的卡。
function c40607210.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end
-- 效果处理：根据宣言的种类，由对方从卡组选择1张该种类的卡送去墓地，若选择成功则执行送墓。
function c40607210.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	-- 向对方玩家发送选择要送去墓地的卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 若宣言的是怪兽：由对方从卡组中选择1张怪兽卡（可送墓）作为送墓对象。
	if e:GetLabel()==0 then g=Duel.SelectMatchingCard(1-tp,c40607210.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	-- 若宣言的是魔法：由对方从卡组中选择1张魔法卡作为送墓对象。
	elseif e:GetLabel()==1 then g=Duel.SelectMatchingCard(1-tp,c40607210.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 若宣言的是陷阱：由对方从卡组中选择1张陷阱卡作为送墓对象。
	else g=Duel.SelectMatchingCard(1-tp,c40607210.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP) end
	if g:GetCount()~=0 then
		-- 将选中的卡以‘效果’为原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
