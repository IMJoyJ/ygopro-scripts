--戦慄の凶皇－ジェネシス・デーモン
-- 效果：
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的这张卡的原本的攻击力·守备力变成一半，结束阶段破坏。
-- ③：只要这张卡在怪兽区域存在，自己不是恶魔族怪兽不能特殊召唤。
-- ④：1回合1次，把自己的手卡·墓地1张「恶魔」卡除外，以场上1张卡为对象才能发动。那张卡破坏。
function c28423537.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。②：这张卡的①的方法召唤的这张卡的原本的攻击力·守备力变成一半，结束阶段破坏。
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
-- 无解放召唤的条件判定：被召唤的卡为等级5以上、要求解放数为0（即无解放）且自己场上主要怪兽区有空位时允许无解放召唤；若c为nil（规则询问是否可用此方式召唤）则返回true。
function c28423537.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断本次召唤是否为无解放召唤（minc==0）、该卡等级是否在5以上、自己场上主要怪兽区是否有空位，全部满足才可无解放召唤。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无解放召唤成功时的处理：为此卡设置原本攻击力为1500、原本守备力为1000（即原本数值的一半），并注册一个在结束阶段破坏此卡的效果。
function c28423537.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法召唤的这张卡的原本的攻击力·守备力变成一半，结束阶段破坏。
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
	-- ②：这张卡的①的方法召唤的这张卡的原本的攻击力·守备力变成一半，结束阶段破坏。
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
-- 自肃效果的判定：要被特殊召唤的怪兽种族不是恶魔族时，禁止该特殊召唤（因此自己只能特殊召唤恶魔族怪兽）。
function c28423537.splimit(e,c,tp,sumtp,sumpos)
	return c:GetRace()~=RACE_FIEND
end
-- 结束阶段时，以效果原因将效果持有者（这张卡）破坏。
function c28423537.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏效果持有者（这张卡）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 检索/选择代价卡的过滤条件：卡名含有「恶魔」且可以作为代价从手卡或墓地除外。
function c28423537.rfilter(c)
	return c:IsSetCard(0x45) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：从手卡或墓地选择1张符合条件的「恶魔」卡表侧除外作为发动代价；先检查是否存在可除外的卡，再选择并除外。
function c28423537.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己手卡或墓地是否存在至少1张符合条件的「恶魔」卡可以除外作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c28423537.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己手卡或墓地中选择1张符合条件的「恶魔」卡用于除外。
	local g=Duel.SelectMatchingCard(tp,c28423537.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标选择处理：以场上1张卡为对象（取对象），并设置破坏1张卡的操作信息；处理时先检查对象合法性，再选择目标。
function c28423537.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 目标合法性检查：场上是否存在至少1张可以作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次效果处理的操作信息为破坏1张卡，供诱发效果等判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若对象仍与此效果相关（未离场或未失效），则将其破坏。
function c28423537.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
