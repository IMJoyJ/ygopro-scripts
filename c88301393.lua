--インフェルノイド・アドラメレク
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地2只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续攻击。
-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c88301393.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地2只「狱火机」怪兽除外的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c88301393.spcon)
	e2:SetTarget(c88301393.sptg)
	e2:SetOperation(c88301393.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88301393,0))  --"连续攻击"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c88301393.atcon)
	e3:SetOperation(c88301393.atop)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(88301393,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c88301393.rmcost)
	e4:SetTarget(c88301393.rmtg)
	e4:SetOperation(c88301393.rmop)
	c:RegisterEffect(e4)
end
-- 过滤手卡·墓地中满足除外条件的「狱火机」怪兽
function c88301393.spfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤场上表侧表示的效果怪兽
function c88301393.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级（超量怪兽返回阶级，其他怪兽返回等级）
function c88301393.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 特殊召唤规则的条件判定函数
function c88301393.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 计算自己场上所有表侧表示效果怪兽的等级·阶级合计值
	local sum=Duel.GetMatchingGroup(c88301393.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c88301393.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取手卡、墓地（或场上）满足除外条件的「狱火机」怪兽组
	local g=Duel.GetMatchingGroup(c88301393.spfilter,tp,loc,0,c)
	-- 检查是否能选出2只怪兽除外，且除外后有足够的怪兽区域空位用于特殊召唤
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤规则的素材选择目标函数
function c88301393.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取手卡、墓地（或场上）可作为除外素材的「狱火机」怪兽组
	local g=Duel.GetMatchingGroup(c88301393.spfilter,tp,loc,0,c)
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择2只除外素材，并确保特殊召唤时有足够的怪兽区域空位
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的具体操作函数
function c88301393.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的素材怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 连续攻击效果的发动条件判定函数
function c88301393.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and c:IsChainAttackable() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 连续攻击效果的处理函数
function c88301393.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使这张卡可以再进行1次攻击
	Duel.ChainAttack()
end
-- 除外效果的发动代价（Cost）处理函数
function c88301393.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只怪兽作为解放的素材
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选定的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 除外效果的目标选择（Target）与发动检测函数
function c88301393.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁信息，表示该效果的操作分类为除外对方墓地的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 除外效果的具体处理（Operation）函数
function c88301393.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
