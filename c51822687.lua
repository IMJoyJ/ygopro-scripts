--エクスピュアリィ・ハピネス
-- 效果：
-- 7星怪兽×2
-- 这张卡也能在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤。
-- ①：自己主要阶段才能发动。这张卡1个超量素材取除，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。这张卡有1星「纯爱妖精」怪兽在作为超量素材的场合，对方不能对应这个效果的发动把效果发动。
-- ②：持有超量素材5个以上的这张卡进行战斗的攻击宣言时发动。给与对方1500伤害。
local s,id,o=GetID()
-- 初始化效果函数，添加超量召唤手续并注册两个效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0))  --"是否在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。这张卡1个超量素材取除，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"对方全部怪兽效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：持有超量素材5个以上的这张卡进行战斗的攻击宣言时发动。给与对方1500伤害。
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
-- 判断是否满足在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤的条件
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(2) and c:GetOverlayCount()>=5
end
-- 检查是否可以移除1个超量素材并确认对方场上存在可被无效化的怪兽
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		-- 确认对方场上存在可被无效化的怪兽
		and Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上所有可被无效化的怪兽组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，将对方场上的所有表侧表示怪兽设为无效化对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	if c:GetOverlayGroup():IsExists(s.check,1,nil) then
		-- 设置连锁限制条件，防止对方在该效果发动时连锁其他效果
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 判断超量素材中是否包含1星「纯爱妖精」怪兽
function s.check(c)
	return c:IsSetCard(0x18c) and c:IsLevel(1)
end
-- 连锁限制函数，仅允许自己连锁自己的效果
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 处理效果无效化操作，移除1个超量素材并使对方场上所有表侧表示怪兽效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有可被无效化的怪兽组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	if c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0 and #g>0 then
		local tc=g:GetFirst()
		while tc do
			-- 使目标怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标怪兽效果无效化
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
-- 判断是否满足攻击宣言时发动伤害效果的条件
function s.damcon(e)
	local c=e:GetHandler()
	-- 判断该卡为攻击怪兽且拥有5个以上超量素材
	return (c==Duel.GetAttacker() or c==Duel.GetAttackTarget()) and c:GetOverlayCount()>=5
end
-- 设置伤害效果的目标和参数
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设定伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害效果的伤害值为1500
	Duel.SetTargetParam(1500)
	-- 设置连锁操作信息，将给与对方1500伤害设为处理对象
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 执行伤害效果，对目标玩家造成1500点伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
