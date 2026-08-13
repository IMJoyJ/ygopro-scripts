--竜の束縛
-- 效果：
-- 以自己场上1只攻击力·守备力是2500以下的龙族怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把作为对象的怪兽的原本攻击力以下的怪兽特殊召唤。
-- ②：作为对象的怪兽从场上离开时这张卡破坏。
function c16278116.initial_effect(c)
	-- 以自己场上1只攻击力·守备力是2500以下的龙族怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c16278116.target)
	c:RegisterEffect(e1)
	-- ①中“作为对象的怪兽”的确定：将发动时选择的对象怪兽设为这张卡的永续对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(c16278116.tgcon)
	e2:SetOperation(c16278116.tgop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把作为对象的怪兽的原本攻击力以下的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c16278116.splimit)
	c:RegisterEffect(e3)
	-- ②：作为对象的怪兽从场上离开时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c16278116.descon)
	e4:SetOperation(c16278116.desop)
	c:RegisterEffect(e4)
end
-- 定义本卡发动时可选择的怪兽条件：表侧表示、龙族、攻击力2500以下且守备力2500以下。
function c16278116.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttackBelow(2500) and c:IsDefenseBelow(2500)
end
-- 发动时的取对象处理：确认对象为对方场上的怪兽时是否合法，并判断是否存在可选择的合法对象。
function c16278116.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c16278116.filter(chkc) end
	-- 效果发动合法性检查（chk==0）：自己场上是否存在至少1只符合条件的龙族怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c16278116.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择表侧表示卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上的表侧表示龙族怪兽中选取1只攻击力·守备力2500以下的怪兽作为对象，并登记为连锁对象。
	Duel.SelectTarget(tp,c16278116.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 触发器条件：当前连锁解决的效果必须是本卡发动效果（e1），即只在本卡发动处理完成时执行后续绑定。
function c16278116.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 发动处理完成后，若本卡与对象卡仍与效果关联且对象卡表侧表示，则将对象卡设为本卡的永续对象。
function c16278116.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取出发动时选择的对象卡（第一个目标）。
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
	if c:IsRelateToEffect(re) and tc:IsFaceup() and tc:IsRelateToEffect(re) then
		c:SetCardTarget(tc)
	end
end
-- 特殊召唤限制判定：若被特殊召唤的怪兽原本攻击力不高于对象怪兽的原本攻击力，则禁止该特殊召唤。
function c16278116.splimit(e,c,tp,sumtp,sumpos)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and c:IsAttackBelow(tc:GetBaseAttack())
end
-- 破坏触发条件：对象怪兽离场且本卡未被预定破坏时，返回真。
function c16278116.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏处理：对象怪兽离场后，将本卡破坏。
function c16278116.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果为原因将这张卡自身破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
