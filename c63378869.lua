--狂愛の竜娘アイザ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。给对方场上1只表侧表示怪兽放置1个狂爱指示物。有狂爱指示物放置的怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：有狂爱指示物放置的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，双方受到那个原本攻击力数值的伤害。这张卡在那次战斗阶段结束时破坏。
local s,id,o=GetID()
-- 初始化这张卡的两个效果：①特殊召唤成功时放置狂爱指示物的诱发选发效果（1回合1次），②与有狂爱指示物的对方怪兽战斗的伤害步骤开始时破坏对方的诱发选发效果（1回合1次）
function s.initial_effect(c)
	-- ①：这张卡特殊召唤的场合才能发动。给对方场上1只表侧表示怪兽放置1个狂爱指示物。
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
	-- ②：有狂爱指示物放置的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，双方受到那个原本攻击力数值的伤害。
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
-- ①效果的发动条件：确认这张卡是被特殊召唤的
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ①效果的对象/发动条件检测：对象须为对方场上可放置狂爱指示物的怪兽；发动时需确认对方场上存在至少1只可以放置1个狂爱指示物的怪兽
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x106b,1) end
	-- 检查对方场上是否存在至少1只可以放置1个狂爱指示物的怪兽，以此决定能否发动
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x106b,1) end
end
-- ①效果的处理：让自己选择对方场上1只可放置狂爱指示物的表侧表示怪兽，放置1个狂爱指示物，并为其注册不能作为同调·融合·超量·连接召唤素材的持续效果
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出「请选择表侧表示的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己选择对方场上1只可以放置1个狂爱指示物的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x106b,1)
	if g:GetCount()>0 then
		-- 为选中的怪兽显示被选为对象的动画并记录
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc:AddCounter(0x106b,1) then
			-- 有狂爱指示物放置的怪兽不能作为融合·同调·超量·连接召唤的素材。（此处先注册不能作为同调素材的效果）
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
-- 素材限制效果的适用条件：该怪兽上放置有狂爱指示物时才适用
function s.mtcon(e)
	return e:GetHandler():GetCounter(0x106b)>0
end
-- 融合素材限制的值函数：仅在该召唤为融合召唤时限制其作为素材
function s.fuslimit(e,c,st)
	return st==SUMMON_TYPE_FUSION
end
-- ②效果的发动条件：确认与这张卡进行战斗的是对方控制的、放置有狂爱指示物的怪兽，并将其记录为标签对象
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:GetCounter(0x106b)>0 and bc:IsRelateToBattle()
end
-- ②效果的目标设定：设定破坏那只对方怪兽的操作信息；若其原本攻击力大于0，再设定双方受到该数值伤害的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设定操作信息：本次连锁处理将破坏那1只对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	if bc:GetTextAttack()>0 then
		-- 设定操作信息：本次连锁处理将让双方受到那只怪兽原本攻击力数值的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,bc:GetTextAttack())
	end
end
-- ②效果的处理：破坏那只对方怪兽，双方受到其原本攻击力数值的伤害，并注册在战斗阶段结束时将这张卡破坏的延迟效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetHandler():GetBattleTarget()
	-- 确认那只对方怪兽仍与战斗相关、为怪兽且由对方控制，然后以效果将其破坏，破坏成功才继续处理
	if bc:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bc:IsControler(1-tp) and Duel.Destroy(bc,REASON_EFFECT)>0 then
		-- 以效果给与对方玩家那只怪兽原本攻击力数值的伤害（分步处理）
		Duel.Damage(1-tp,bc:GetTextAttack(),REASON_EFFECT,true)
		-- 以效果给与自己玩家那只怪兽原本攻击力数值的伤害（分步处理）
		Duel.Damage(tp,bc:GetTextAttack(),REASON_EFFECT,true)
		-- 配合分步伤害处理，触发伤害发生的时点
		Duel.RDComplete()
	end
	local fid=e:GetHandler():GetFieldID()
	c:RegisterFlagEffect(id,RESET_EVENT+0x47c0000+RESET_PHASE+PHASE_BATTLE,0,1,fid)
	-- 这张卡在那次战斗阶段结束时破坏。（注册战斗阶段结束时破坏这张卡的延迟效果）
	local de=Effect.CreateEffect(c)
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_BATTLE)
	de:SetReset(RESET_PHASE+PHASE_BATTLE)
	de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	de:SetCountLimit(1)
	de:SetLabel(fid)
	de:SetLabelObject(c)
	de:SetOperation(s.desop2)
	-- 把战斗阶段结束时破坏这张卡的延迟效果注册给全局环境
	Duel.RegisterEffect(de,tp)
end
-- 战斗阶段结束时的延迟处理：确认这张卡仍是当时登记的那张卡（场地ID一致），然后将其破坏
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=e:GetLabel()
	if tc:GetFlagEffectLabel(id)==fid then
		-- 以效果将这张卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
