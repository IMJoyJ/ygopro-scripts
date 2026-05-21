--熾天の騎士ガイアプロミネンス
-- 效果：
-- 「烈日之骑士 盖亚烈焰」＋自己场上的表侧表示怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把手卡·墓地的怪兽的效果发动时，从手卡丢弃1只怪兽才能发动。那个效果无效并破坏。
-- ②：这张卡的攻击破坏对方怪兽时，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤手续，注册①效果（无效并破坏）和②效果（战破特召）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：以1只「烈日之骑士 盖亚烈焰」和自己场上的1只表侧表示怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,9709452,s.mfilter,1,true,true)
	-- ①：对方把手卡·墓地的怪兽的效果发动时，从手卡丢弃1只怪兽才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击破坏对方怪兽时，以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
c95095116.material_type=TYPE_SYNCHRO
-- 融合素材过滤条件：自己场上表侧表示的怪兽
function s.mfilter(c,fc)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(fc:GetControler())
end
-- ①效果的发动条件：此卡不在伤害步骤被破坏，对方发动了手卡或墓地的怪兽效果，且该效果可以被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前发动效果的卡片在连锁发动时的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		-- 判定效果发动的位置是否在手卡或墓地，且该效果可以被无效
		and loc&(LOCATION_HAND|LOCATION_GRAVE)>0 and Duel.IsChainDisablable(ev)
end
-- 过滤手卡中可以丢弃的怪兽卡（用于①效果的Cost）
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ①效果的发动代价：从手卡丢弃1只怪兽
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并以丢弃和Cost为原因将1张手卡怪兽送去墓地
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动准备：设置无效和破坏的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	-- 如果发动效果的卡与该效果有关联且可以被破坏，则设置操作信息：破坏该卡
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0) end
end
-- ①效果的处理：使效果无效并破坏该卡
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 如果成功使效果无效，且该卡仍与效果关联，则将其破坏
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then Duel.Destroy(eg,REASON_EFFECT) end
end
-- ②效果的发动条件：此卡进行过战斗且是攻击怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定此卡是否仍与战斗关联，且此卡是本次战斗的攻击方
	return c:IsRelateToBattle() and Duel.GetAttacker()==c
end
-- 过滤自己墓地中可以特殊召唤的炎属性怪兽
function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：检查怪兽区域空位，选择墓地中的1只炎属性怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查自己墓地是否存在至少1只满足条件的炎属性怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的炎属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选择的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：将作为对象的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的第一个对象
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽仍与效果关联，则将其以表侧表示特殊召唤到自己场上
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
