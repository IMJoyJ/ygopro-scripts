--狂愛の竜娘アイザ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。给对方场上1只表侧表示怪兽放置1个狂爱指示物。有狂爱指示物放置的怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：有狂爱指示物放置的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，双方受到那个原本攻击力数值的伤害。这张卡在那次战斗阶段结束时破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册①特召放置狂爱指示物效果、②与有狂爱指示物怪兽战斗破坏对方并扣血效果
function s.initial_effect(c)
	-- ①：这张卡特殊召唤的场合才能发动。给对方场上1只表侧表示怪兽放置1个狂爱指示物。有狂爱指示物放置的怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- ②：有狂爱指示物放置的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，双方受到那只怪兽原本攻击力数值的伤害。这张卡在那次战斗阶段结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏对方怪兽"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x106b]=true,
}
-- ①效果发动条件：此卡特殊召唤成功
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 放置指示物效果目标选择与发动准备：检查对方场上是否存在可放置狂爱指示物的怪兽
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x106b,1) end
	-- 发动条件检查：对方场上是否存在可以放置狂爱指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x106b,1) end
end
-- 放置指示物效果处理：给对方场上1只表侧表示怪兽放置1个狂爱指示物，并使其不能作为融合/同调/超量/连接召唤素材
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择对方场上的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只可以放置狂爱指示物的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x106b,1)
	if g:GetCount()>0 then
		-- 高亮显示选中的怪兽
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc:AddCounter(0x106b,1) then
			-- 素材限制效果：有狂爱指示物放置的怪兽不能作为融合·同调·超量·连接召唤的素材
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.mtcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetValue(s.fuslimit)
			e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e3)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e4)
		end
	end
end
-- 素材限制生效条件：怪兽身上仍存在狂爱指示物
function s.mtcon(e)
	return e:GetHandler():GetCounter(0x106b)>0
end
-- 融合素材限制条件：仅在融合召唤时限制作为素材
function s.fuslimit(e,c,st)
	return st==SUMMON_TYPE_FUSION
end
-- ②效果发动条件：与有狂爱指示物的对方怪兽进行战斗
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:GetCounter(0x106b)>0 and bc:IsRelateToBattle()
end
-- 破坏与伤害效果发动准备：设置破坏战斗对方怪兽及双方受伤害的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置连锁操作信息：破坏战斗对方怪兽1只
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	if bc:GetTextAttack()>0 then
		-- 设置连锁操作信息：给予双方该怪兽原本攻击力数值的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,bc:GetTextAttack())
	end
end
-- ②效果处理：破坏对方怪兽、双方各受伤害，并注册战斗阶段结束时自毁的延迟效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetHandler():GetBattleTarget()
	-- 确认战斗对象仍合法并成功将其破坏
	if bc:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bc:IsControler(1-tp) and Duel.Destroy(bc,REASON_EFFECT)>0 then
		-- 给予对方破坏怪兽原本攻击力数值的伤害（暂存伤害）
		Duel.Damage(1-tp,bc:GetTextAttack(),REASON_EFFECT,true)
		-- 给予自己破坏怪兽原本攻击力数值的伤害（暂存伤害）
		Duel.Damage(tp,bc:GetTextAttack(),REASON_EFFECT,true)
		-- 结算并同时应用双方受到的效果伤害
		Duel.RDComplete()
	end
	local fid=e:GetHandler():GetFieldID()
	c:RegisterFlagEffect(id,RESET_EVENT+0x47c0000+RESET_PHASE+PHASE_BATTLE,0,1,fid)
	-- 战斗阶段结束自毁效果：在此次战斗阶段结束时将自身破坏
	local de=Effect.CreateEffect(c)
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_BATTLE)
	de:SetReset(RESET_PHASE+PHASE_BATTLE)
	de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	de:SetCountLimit(1)
	de:SetLabel(fid)
	de:SetLabelObject(c)
	de:SetOperation(s.desop2)
	-- 注册延迟至战斗阶段结束时生效的全局效果
	Duel.RegisterEffect(de,tp)
end
-- 战斗阶段结束自毁处理：确认Flag标记匹配后破坏自身
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=e:GetLabel()
	if tc:GetFlagEffectLabel(id)==fid then
		-- 因效果将自身破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
