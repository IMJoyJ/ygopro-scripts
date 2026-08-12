--オーバーレイ・ブースター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有攻击力2000以上的怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以持有超量素材的自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力上升自身的超量素材数量×500。
function c75214390.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有攻击力2000以上的怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,75214390+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c75214390.spcon)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以持有超量素材的自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力上升自身的超量素材数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75214390,0))  --"攻击变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果发动条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置效果发动Cost：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c75214390.atktg)
	e2:SetOperation(c75214390.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且攻击力在2000以上的怪兽。
function c75214390.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000)
end
-- 特殊召唤规则的条件判定函数。
function c75214390.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在攻击力2000以上的怪兽。
		and Duel.IsExistingMatchingCard(c75214390.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：表侧表示且持有超量素材的怪兽。
function c75214390.filter(c)
	return c:IsFaceup() and c:GetOverlayCount()>0
end
-- 攻击力上升效果的对象选择与判定函数。
function c75214390.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c75214390.filter(chkc) end
	-- 在效果发动阶段，检查自己场上是否存在可以作为对象的、持有超量素材的超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c75214390.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只持有超量素材的超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c75214390.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 攻击力上升效果的实际处理函数。
function c75214390.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升自身的超量素材数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetOverlayCount()*500)
		tc:RegisterEffect(e1)
	end
end
