--エクスピュアリィ・ハピネス
-- 效果：
-- 7星怪兽×2
-- 这张卡也能在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤。
-- ①：自己主要阶段才能发动。这张卡1个超量素材取除，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。这张卡有1星「纯爱妖精」怪兽在作为超量素材的场合，对方不能对应这个效果的发动把效果发动。
-- ②：持有超量素材5个以上的这张卡进行战斗的攻击宣言时发动。给与对方1500伤害。
local s,id,o=GetID()
-- 初始化效果处理：为卡片设置超量召唤手续（7星怪兽×2，或满足ovfilter条件的5个素材以上2阶怪兽上方重叠），并注册①的起动效果（无效对方全部表侧怪兽效果）和②的攻击宣言时给与伤害的诱发效果。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0))  --"是否在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 对应效果原文①：“①：自己主要阶段才能发动。这张卡1个超量素材取除，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。这张卡有1星「纯爱妖精」怪兽在作为超量素材的场合，对方不能对应这个效果的发动把效果发动。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"对方全部怪兽效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 对应效果原文②：“②：持有超量素材5个以上的这张卡进行战斗的攻击宣言时发动。给与对方1500伤害。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"给与对方1500伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
-- 超量召唤的追加素材筛选：判断候选怪兽是否为表侧表示的超量怪兽、阶级为2，且拥有5个以上超量素材，满足“也能在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤”的条件。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(2) and c:GetOverlayCount()>=5
end
-- 起动效果发动条件的检查：确认自己场上这张卡可以取除1个超量素材，且对方场上有表侧表示且效果未被无效的效果怪兽存在。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		-- 确认对方场上存在至少1只可以被无效的表侧表示效果怪兽，作为效果发动前提。
		and Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示该效果的发动，显示效果描述文本。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上所有满足“表侧表示且未被无效的效果怪兽”的卡组，准备作为无效对象。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 将无效这些怪兽的信息写入操作信息，供连锁判定；g的数量为预计处理的数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	if c:GetOverlayGroup():IsExists(s.check,1,nil) then
		-- 当这张卡的超量素材中存在1星「纯爱妖精」怪兽时，设置连锁限制，使对方不能对应此效果的发动来发动效果。
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 检查超量素材中是否存在卡名属于「纯爱妖精」系列且等级为1的怪兽。
function s.check(c)
	return c:IsSetCard(0x18c) and c:IsLevel(1)
end
-- 连锁限制判定：只允许效果发动者本人在此连锁后续发动效果，从而禁止对方对应发动（tp==rp表示连锁发起者与当前效果发动者为同一玩家）。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 效果处理：先取除这张卡的1个超量素材作为代价，若取除成功且存在对方场上需要无效的怪兽，则将那些怪兽的效果无效化直到回合结束。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上需要被无效的表侧效果怪兽集合，用于逐个赋予无效效果。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	if c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0 and #g>0 then
		local tc=g:GetFirst()
		while tc do
			-- 对应效果原文“对方场上的全部表侧表示怪兽的效果直到回合结束时无效”中的无效效果赋予部分：使该怪兽的效果无效（EFFECT_DISABLE）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 对应效果原文“对方场上的全部表侧表示怪兽的效果直到回合结束时无效”中的持续无效化部分：使该怪兽已发动的效果也被无效（EFFECT_DISABLE_EFFECT），并持续到回合结束。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
-- 战斗伤害诱发效果的发动条件：此卡参与攻击宣言（是攻击宣言怪兽或攻击对象），并且其超量素材数量为5个以上。
function s.damcon(e)
	local c=e:GetHandler()
	-- 条件表达式：攻击宣言涉及的卡中包含此卡，且此卡持有5个以上超量素材。
	return (c==Duel.GetAttacker() or c==Duel.GetAttackTarget()) and c:GetOverlayCount()>=5
end
-- 伤害效果的目标处理：无条件可发动，设置对象玩家为对方、伤害数值为1500，并将伤害操作信息写入连锁。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示正在发动的伤害效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前连锁的效果对象玩家设为对方玩家，作为伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果参数设置为1500，表示要造成的伤害数值。
	Duel.SetTargetParam(1500)
	-- 设置操作信息：将对对方玩家造成1500点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 伤害效果的实际处理：从连锁信息中取出对象玩家和伤害数值，执行伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害参数，用于后续造成伤害。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给予玩家p共d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
