--終刻起動『D.O.O.M.D.U.R.G.』
-- 效果：
-- ①：自己·对方的准备阶段发动。给与装备怪兽的控制者500伤害。
-- ②：有这张卡装备的「终刻」怪兽或者有这张卡在作为超量素材中的机械族·风属性超量怪兽得到以下效果。
-- ●对方不能把这张卡作为效果的对象。
-- ●自己·对方回合1次，可以发动。自己场上1张其他的表侧表示卡破坏。这张卡在这个回合攻击力上升这张卡的等级·阶级×100，可以直接攻击，进行战斗的伤害步骤结束时破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义装备魔法的发动、准备阶段伤害效果、赋予装备怪兽/超量素材怪兽抗性与主动效果、以及使装备怪兽/超量素材怪兽视作效果怪兽等效果
function s.initial_effect(c)
	-- 注册装备魔法的标准发动效果，允许装备给场上任意表侧表示怪兽
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- ①：自己·对方的准备阶段发动。给与装备怪兽的控制者500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"给与伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	-- ●对方不能把这张卡作为效果的对象。（有这张卡装备的「终刻」怪兽得到的效果）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.ibcon)
	e2:SetValue(s.tgoval)
	c:RegisterEffect(e2)
	-- ●对方不能把这张卡作为效果的对象。（有这张卡在作为超量素材中的机械族·风属性超量怪兽得到的效果）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetCondition(s.tgcon)
	-- 设置不能成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ●自己·对方回合1次，可以发动。自己场上1张其他的表侧表示卡破坏。这张卡在这个回合攻击力上升这张卡的等级·阶级×100，可以直接攻击，进行战斗的伤害步骤结束时破坏。（定义赋予装备怪兽的主动效果）
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"破坏（终刻起动『终末龙雷』）"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	-- ②：有这张卡装备的「终刻」怪兽或者有这张卡在作为超量素材中的机械族·风属性超量怪兽得到以下效果。（将主动效果赋予装备怪兽）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e6:SetCondition(s.tgcon)
	c:RegisterEffect(e6)
	-- ②：有这张卡装备的「终刻」怪兽或者有这张卡在作为超量素材中的机械族·风属性超量怪兽得到以下效果。（使装备的通常怪兽视作效果怪兽）
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_EQUIP)
	e7:SetCode(EFFECT_ADD_TYPE)
	e7:SetValue(TYPE_EFFECT)
	e7:SetCondition(s.efcon)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_REMOVE_TYPE)
	e8:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e8)
	-- ②：有这张卡装备的「终刻」怪兽或者有这张卡在作为超量素材中的机械族·风属性超量怪兽得到以下效果。（使作为超量素材的通常怪兽视作效果怪兽）
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_XMATERIAL)
	e9:SetCode(EFFECT_ADD_TYPE)
	e9:SetValue(TYPE_EFFECT)
	e9:SetCondition(s.tgcon)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EFFECT_REMOVE_TYPE)
	e10:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e10)
end
-- 装备怪兽抗性效果的启用条件：装备怪兽是「终刻」怪兽且未被无效
function s.ibcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:IsSetCard(0x1d2) and not ec:IsDisabled()
end
-- 过滤效果指向，判定效果发动者是否为装备怪兽控制者的对手
function s.tgoval(e,re,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return rp~=ec:GetControler()
end
-- 准备阶段伤害效果的发动条件：这张卡有装备怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 准备阶段伤害效果的靶向与操作信息注册，确定受到伤害的玩家为装备怪兽的控制者，伤害数值为500
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dp=e:GetHandler():GetEquipTarget():GetControler()
	if chk==0 then return true end
	-- 设置受到伤害的目标玩家为装备怪兽的控制者
	Duel.SetTargetPlayer(dp)
	-- 设置伤害数值为500
	Duel.SetTargetParam(500)
	-- 注册连锁操作信息，分类为伤害，目标玩家为dp，数值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,dp,500)
end
-- 准备阶段伤害效果的执行函数，获取目标玩家和伤害数值并给予伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依照效果对目标玩家造成伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果赋予的目标过滤：装备了这张卡的「终刻」怪兽
function s.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1d2) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 超量素材效果的启用条件：作为超量素材的怪兽是机械族·风属性怪兽
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 赋予的主动效果的发动准备，检查场上是否有其他表侧表示卡片可供破坏，并注册破坏操作信息
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上除自身以外的所有表侧表示卡片
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return g:GetCount()>0 and s.lv_or_rk(c)>0 end
	-- 注册连锁操作信息，分类为破坏，目标为获取的卡片组中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"破坏（终刻起动『终末龙雷』）"
end
-- 辅助函数，获取怪兽的等级或阶级并乘以100，若无则返回0
function s.lv_or_rk(c)
	if c:IsLevelAbove(1) then
		return c:GetLevel()*100
	elseif c:IsRankAbove(1) then
		return c:GetRank()*100
	else
		return 0
	end
end
-- 赋予的主动效果的执行函数，选择并破坏自己场上1张其他的表侧表示卡，然后使自身攻击力上升、获得直接攻击能力、并注册在伤害步骤结束时破坏的效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置选择提示信息为“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1张除自身以外的表侧表示卡片
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 闪烁显示被选择的卡片
		Duel.HintSelection(g)
		-- 破坏被选择的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 这张卡在这个回合攻击力上升这张卡的等级·阶级×100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(s.lv_or_rk(c))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 可以直接攻击
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		-- 进行战斗的伤害步骤结束时破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
end
-- 伤害步骤结束时破坏自身的效果执行函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsFaceup() then
		-- 破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 装备怪兽类型变更效果的启用条件：装备怪兽是「终刻」怪兽
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:IsSetCard(0x1d2)
end
