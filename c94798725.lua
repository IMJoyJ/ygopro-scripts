--超弩級軍貫－うに型二番艦
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。
-- ●「舍利军贯」：自己从卡组抽1张。
-- ●「海胆军贯」：这张卡可以直接攻击。
-- ②：自己主要阶段以及对方战斗阶段1次，以最多有从额外卡组特殊召唤的自己的「军贯」怪兽数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果无效。
function c94798725.initial_effect(c)
	-- 注册卡片记有「舍利军贯」和「海胆军贯」的卡片密码
	aux.AddCodeList(c,24639891,42377643)
	-- 添加超量召唤手续：5星怪兽×2
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c94798725.valcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡超量召唤成功的场合才能发动。那些作为超量召唤的素材的怪兽的以下效果适用。●「舍利军贯」：自己从卡组抽1张。●「海胆军贯」：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94798725,0))  --"按素材种类适用效果"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,94798725)
	e1:SetCondition(c94798725.effcon)
	e1:SetTarget(c94798725.efftg)
	e1:SetOperation(c94798725.effop)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
	-- ②：自己主要阶段以及对方战斗阶段1次，以最多有从额外卡组特殊召唤的自己的「军贯」怪兽数量的对方场上的表侧表示的卡为对象才能发动。那些卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94798725,1))  --"对方卡的效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c94798725.discon)
	e2:SetTarget(c94798725.distg)
	e2:SetOperation(c94798725.disop)
	c:RegisterEffect(e2)
end
-- 超量召唤素材检查函数，判断素材中是否存在「舍利军贯」和「海胆军贯」并记录标志
function c94798725.valcheck(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=0
	if c:GetMaterial():FilterCount(Card.IsCode,nil,24639891)>0 then flag=flag|1 end
	if c:GetMaterial():FilterCount(Card.IsCode,nil,42377643)>0 then flag=flag|2 end
	e:GetLabelObject():SetLabel(flag)
end
-- 效果①的发动条件：这张卡超量召唤成功
function c94798725.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的发动检测与效果分类设置函数
function c94798725.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	-- 发动检测：若素材有「舍利军贯」则需满足玩家能抽卡，或者素材有「海胆军贯」
	if chk==0 then return (chk1 and Duel.IsPlayerCanDraw(tp,1) or chk2) end
	if chk1 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置操作信息：玩家从卡组抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(0)
	end
end
-- 效果①的处理函数：根据素材种类适用对应的效果
function c94798725.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	if chk1 then
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if chk2 and c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续效果不视为同时处理
		Duel.BreakEffect()
		-- ●「海胆军贯」：这张卡可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：自己主要阶段或者对方战斗阶段
function c94798725.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前回合玩家
	local turn=Duel.GetTurnPlayer()
	return (turn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) or turn==1-tp and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end
-- 过滤函数：从额外卡组特殊召唤的表侧表示的「军贯」怪兽
function c94798725.ctfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsSetCard(0x166)
end
-- 效果②的靶向与发动检测函数
function c94798725.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己场上从额外卡组特殊召唤的表侧表示「军贯」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c94798725.ctfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 对象重构筛选：对方场上可以被无效的卡
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 发动检测：自己场上存在上述「军贯」怪兽，且对方场上存在至少1张可以被无效的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择最多等同于上述「军贯」怪兽数量的对方场上可以被无效的卡作为对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：使选中的卡片效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果②的处理函数：使作为对象的卡片效果无效
function c94798725.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与此效果相关的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=tg:GetFirst()
	while tc do
		-- 使与目标卡片相关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那些卡的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那些卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那些卡的效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=tg:GetNext()
	end
end
