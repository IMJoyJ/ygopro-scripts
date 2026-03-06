--戦慄の凶皇－ジェネシス・デーモン
-- 效果：
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的这张卡的原本的攻击力·守备力变成一半，结束阶段破坏。
-- ③：只要这张卡在怪兽区域存在，自己不是恶魔族怪兽不能特殊召唤。
-- ④：1回合1次，把自己的手卡·墓地1张「恶魔」卡除外，以场上1张卡为对象才能发动。那张卡破坏。
function c28423537.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28423537,0))  --"不解放进行召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c28423537.ntcon)
	e1:SetOperation(c28423537.ntop)
	c:RegisterEffect(e1)
	-- ③：只要这张卡在怪兽区域存在，自己不是恶魔族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c28423537.splimit)
	c:RegisterEffect(e2)
	-- ④：1回合1次，把自己的手卡·墓地1张「恶魔」卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28423537,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c28423537.descost)
	e3:SetTarget(c28423537.destg)
	e3:SetOperation(c28423537.desop)
	c:RegisterEffect(e3)
end
-- 判断是否满足不解放召唤的条件，即召唤时不需要解放且等级不低于5，且场上存在可用怪兽区域。
function c28423537.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足不解放召唤的条件：召唤时不需要解放（minc==0），等级不低于5，且场上存在可用怪兽区域。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 设置召唤时的原本攻击力为1500，原本守备力为1000，并在结束阶段触发破坏效果。
function c28423537.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置自身原本攻击力为1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1500)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 在结束阶段时，将自身破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(c28423537.tgop)
	e3:SetReset(RESET_EVENT+0xc6e0000)
	c:RegisterEffect(e3)
end
-- 限制非恶魔族怪兽不能特殊召唤。
function c28423537.splimit(e,c,tp,sumtp,sumpos)
	return c:GetRace()~=RACE_FIEND
end
-- 在结束阶段时，将自身破坏。
function c28423537.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身以效果原因破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤手卡或墓地中的恶魔族卡作为除外的代价。
function c28423537.rfilter(c)
	return c:IsSetCard(0x45) and c:IsAbleToRemoveAsCost()
end
-- 支付除外1张恶魔族卡作为发动代价。
function c28423537.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在恶魔族卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c28423537.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的恶魔族卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张手卡或墓地的恶魔族卡进行除外。
	local g=Duel.SelectMatchingCard(tp,c28423537.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的恶魔族卡除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置发动效果时选择破坏对象。
function c28423537.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可破坏的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定破坏对象数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将选中的卡破坏。
function c28423537.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
