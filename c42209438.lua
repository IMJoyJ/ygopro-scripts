--真魔六武衆－キザン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的「六武众」怪兽的攻击力·守备力只在战斗阶段内上升600。
-- ②：对方主要阶段，从自己墓地把1张「六武式」卡除外，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：自己场上有「六武众」怪兽2只以上存在的场合才能发动。这张卡从墓地特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤条件并注册所有效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：自己场上的「六武众」怪兽的攻击力在战斗阶段内上升600
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果①的目标为「六武众」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x103d))
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 效果②：对方主要阶段时，从墓地除外1张「六武式」卡，破坏场上1张卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- 效果③：自己场上有2只以上「六武众」怪兽时，可以从墓地特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：当前为战斗阶段
function s.atkcon(e)
	-- 判断当前是否为战斗阶段
	return Duel.IsBattlePhase()
end
-- 效果②的发动条件：当前为对方主要阶段
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方主要阶段
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件函数：判断卡是否为「六武式」且可作为除外费用
function s.cfilter(c)
	return c:IsSetCard(0x203d) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动费用：从墓地选择1张「六武式」卡除外
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动目标选择：选择场上1张卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足选择目标条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理：破坏目标卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍存在于场上则破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 过滤条件函数：判断卡是否为「六武众」且表侧表示
function s.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 效果③的发动条件：自己场上有2只以上「六武众」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有无2只以上「六武众」怪兽
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果③的发动准备：检查是否有特殊召唤空间及卡是否可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的处理：将卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否可特殊召唤（未被王家长眠之谷影响）
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
