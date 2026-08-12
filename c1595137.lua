--暁世竜ダニアン
-- 效果：
-- 「新世龙 丹」＋恐龙族怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「基因组混合」卡加入手卡。
-- ②：自己用「基因组混合」卡的效果把卡组的卡翻开的场合，可以把以这张卡在哪里存在来对应的以下效果发动（这个卡名的以下效果1回合各能使用1次）。
-- ●场上：自己回复1500基本分。
-- ●墓地：这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制，注册融合召唤手续，并注册①效果（特殊召唤成功时检索「基因组混合」卡）、②效果的场上版本（翻开卡组时回复1500基本分）和墓地版本（特殊召唤自身）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号29927283的「新世龙 丹」加上1只恐龙族怪兽为融合素材
	aux.AddFusionProcCodeFun(c,29927283,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),1,true,true)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「基因组混合」卡加入手卡。
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
	-- ②：自己用「基因组混合」卡的效果把卡组的卡翻开的场合，可以把以这张卡在哪里存在来对应的以下效果发动（这个卡名的以下效果1回合各能使用1次）。●场上：自己回复1500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动效果"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.accon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.accon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检索过滤函数：判断卡是否属于「基因组混合」系列（0x1dd）且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsAbleToHand()
end
-- ①效果的目标函数：确认卡组中存在可加入手卡的「基因组混合」卡，并设置从卡组加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查自己卡组中是否存在至少1张满足条件的「基因组混合」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁将把卡组的1张卡加入发动玩家的手卡（具体卡在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：提示选择要加入手卡的卡，从卡组选1张「基因组混合」卡加入手卡，并让对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示「请选择要加入手牌的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足条件的「基因组混合」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果处理的原因把选中的卡加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：只有自己是「基因组混合」卡效果的发动者（即自己翻开卡组的卡）时才能发动
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
-- 回复效果的目标函数：设置连锁的对象玩家为自己、对象参数为1500，并设置回复1500基本分的操作信息
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设置为发动玩家自己
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的对象参数设置为1500（回复的基本分数值）
	Duel.SetTargetParam(1500)
	-- 设置操作信息：本连锁将使发动玩家回复1500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
-- 回复效果的处理：读取连锁的对象玩家和对象参数，以效果处理的原因使其回复相应基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中的对象玩家和对象参数（即自己和1500）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果处理的原因让对象玩家回复1500基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 墓地②效果的目标函数：确认自己主要怪兽区有空位且这张卡可以被特殊召唤，并设置特殊召唤自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查自己的主要怪兽区是否存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将把这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地②效果的处理：若这张卡仍与连锁关联且不受王家长眠之谷影响，则将其以表侧表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前检查：确认这张卡仍与该连锁关联，且不被王家长眠之谷的效果所限制
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到发动玩家自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
