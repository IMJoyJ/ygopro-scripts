--時の沈黙-ターン・サイレンス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级上升3星。自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的状态，连锁对方怪兽的效果的发动把这张卡发动的场合，那个对方的效果无效。
-- ②：有「光之黄金柜」的卡名记述的自己怪兽进行战斗的伤害计算时，把墓地的这张卡除外才能发动。那次战斗阶段结束。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片关联卡名注册、①效果（卡片发动：等级上升与效果无效）和②效果（墓地诱发：结束战斗阶段）。
function s.initial_effect(c)
	-- 注册该卡的效果文本中记载了「光之黄金柜」的卡名。
	aux.AddCodeList(c,79791878)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级上升3星。自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的状态，连锁对方怪兽的效果的发动把这张卡发动的场合，那个对方的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：有「光之黄金柜」的卡名记述的自己怪兽进行战斗的伤害计算时，把墓地的这张卡除外才能发动。那次战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.bacon)
	-- 设置效果发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.baop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示且有等级的怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- ①效果的发动准备：检查并选择自己场上1只表侧表示怪兽作为对象。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	-- 检查自己场上是否存在至少1只可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的怪兽并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤条件：场上表侧表示的「光之黄金柜」。
function s.nfilter1(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 过滤条件：场上表侧表示的、有「光之黄金柜」卡名记述的怪兽。
function s.nfilter2(c)
	-- 过滤条件：卡片表侧表示且其效果文本中记载了「光之黄金柜」的卡名。
	return c:IsFaceup() and aux.IsCodeListed(c,79791878)
end
-- ①效果的处理：使对象怪兽等级上升3星；若满足特定条件且连锁对方怪兽效果发动，则将该对方效果无效。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的等级上升3星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 获取当前的连锁序号。
	local ct=Duel.GetCurrentChain()
	if ct<2 then return end
	-- 获取前一个连锁（即直接连锁这张卡发动的效果）的效果对象和发动玩家。
	local te,tep=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	-- 检查是否连锁对方怪兽的效果发动，且自己场上是否存在「光之黄金柜」以及有该卡名记述的怪兽。
	if tep==1-tp and te:IsActiveType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.nfilter1,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(s.nfilter2,tp,LOCATION_MZONE,0,1,nil) then
		-- 无效前一个连锁（对方怪兽）的效果。
		Duel.NegateEffect(ct-1)
	end
end
-- ②效果的发动条件：伤害计算时，进行战斗的自己怪兽是有「光之黄金柜」卡名记述的怪兽。
function s.bacon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标切换为被攻击的自己怪兽。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc then return false end
	e:SetLabelObject(tc)
	-- 检查进行战斗的自己怪兽是否表侧表示，且其效果文本中记载了「光之黄金柜」的卡名。
	return tc:IsFaceup() and aux.IsCodeListed(tc,79791878)
end
-- ②效果的处理：无效该次攻击，并跳过该回合的战斗阶段（使战斗阶段结束）。
function s.baop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 无效当前的攻击。
		Duel.NegateAttack()
		-- 那次战斗阶段结束。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetReset(RESET_PHASE+PHASE_END,1)
		-- 将跳过战斗阶段的效果注册给当前回合玩家。
		Duel.RegisterEffect(e1,Duel.GetTurnPlayer())
	end
end
