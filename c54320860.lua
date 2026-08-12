--インフェルニティ・ビショップ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己手卡只有这1张卡的场合，这张卡可以从手卡特殊召唤。
-- ②：只要自己手卡是0张，自己场上的「永火」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c54320860.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己手卡只有这1张卡的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,54320860+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c54320860.spcon)
	c:RegisterEffect(e1)
	-- ②：只要自己手卡是0张，自己场上的「永火」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c54320860.reptg)
	e2:SetValue(c54320860.repval)
	e2:SetOperation(c54320860.repop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件函数，判断手牌数量和怪兽区域空位数是否满足特殊召唤要求
function c54320860.spcon(e,c)
	if c==nil then return true end
	-- 检查自己手牌数量是否只有1张（即只有这张卡自身）
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)==1
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤自己场上表侧表示、属于「永火」系列且不是因为代替破坏而被破坏的怪兽
function c54320860.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0xb) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的Target函数，检查手牌是否为0、是否有符合条件的怪兽被破坏以及此卡是否能除外
function c54320860.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在第一阶段（chk==0）检查自己手牌数量是否为0张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		and eg:IsExists(c54320860.filter,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	-- 询问玩家是否选择发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的Value函数，用于确定哪些怪兽适用此代替破坏效果
function c54320860.repval(e,c)
	return c54320860.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的Operation函数，执行将墓地的这张卡除外的操作
function c54320860.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡以表侧表示除外，作为代替破坏的手段
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
