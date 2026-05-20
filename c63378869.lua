--狂愛の竜娘アイザ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。给对方场上1只表侧表示怪兽放置1个狂爱指示物。有狂爱指示物放置的怪兽不能作为融合·同调·超量·连接召唤的素材。
-- ②：有狂爱指示物放置的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，双方受到那个原本攻击力数值的伤害。这张卡在那次战斗阶段结束时破坏。
local s,id,o=GetID()
-- 注册卡片效果：①特殊召唤时给对方怪兽放置狂爱指示物；②与有狂爱指示物的怪兽战斗时破坏该怪兽并给予双方伤害，自身在战斗阶段结束时破坏。
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
	-- ②：有狂爱指示物放置的对方怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏，双方受到那个原本攻击力数值的伤害。这张卡在那次战斗阶段结束时破坏。
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
-- 检查此卡是否特殊召唤成功，作为效果①的发动条件。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果①的发动准备与合法性检查，确认对方场上是否存在可以放置狂爱指示物的表侧表示怪兽。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x106b,1) end
	-- 检查对方场上是否存在至少1只可以放置狂爱指示物（0x106b）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x106b,1) end
end
-- 效果①的处理：选择对方场上1只表侧表示怪兽放置1个狂爱指示物，并为其注册不能作为融合、同调、超量、连接召唤素材的效果。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择1张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只可以放置狂爱指示物的怪兽。
	local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x106b,1)
	if g:GetCount()>0 then
		-- 显式示出被选择的怪兽。
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc:AddCounter(0x106b,1) then
			-- 有狂爱指示物放置的怪兽不能作为融合·同调·超量·连接召唤的素材。
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
-- 限制素材效果的适用条件：该怪兽身上仍有狂爱指示物存在。
function s.mtcon(e)
	return e:GetHandler():GetCounter(0x106b)>0
end
-- 限制该怪兽不能作为融合召唤的素材。
function s.fuslimit(e,c,st)
	return st==SUMMON_TYPE_FUSION
end
-- 效果②的发动条件：伤害步骤开始时，此卡与有狂爱指示物放置的对方怪兽进行战斗。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:GetCounter(0x106b)>0 and bc:IsRelateToBattle()
end
-- 效果②的发动准备，设置破坏对方怪兽以及给予双方伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置破坏对方战斗怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	if bc:GetTextAttack()>0 then
		-- 设置给予双方玩家该怪兽原本攻击力数值伤害的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,bc:GetTextAttack())
	end
end
-- 效果②的处理：破坏对方怪兽，给予双方其原本攻击力数值的伤害，并注册在此次战斗阶段结束时将自身破坏的效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查对方怪兽是否仍处于战斗关系且为怪兽卡，并将其因效果破坏。
	if bc:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bc:IsControler(1-tp) and Duel.Destroy(bc,REASON_EFFECT)>0 then
		-- 给予对方玩家该怪兽原本攻击力数值的伤害（分步处理）。
		Duel.Damage(1-tp,bc:GetTextAttack(),REASON_EFFECT,true)
		-- 给予自己玩家该怪兽原本攻击力数值的伤害（分步处理）。
		Duel.Damage(tp,bc:GetTextAttack(),REASON_EFFECT,true)
		-- 结束分步伤害处理，触发受到伤害的时点。
		Duel.RDComplete()
	end
	local fid=e:GetHandler():GetFieldID()
	c:RegisterFlagEffect(id,RESET_EVENT+0x47c0000+RESET_PHASE+PHASE_BATTLE,0,1,fid)
	-- 这张卡在那次战斗阶段结束时破坏。
	local de=Effect.CreateEffect(c)
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_BATTLE)
	de:SetReset(RESET_PHASE+PHASE_BATTLE)
	de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	de:SetCountLimit(1)
	de:SetLabel(fid)
	de:SetLabelObject(c)
	de:SetOperation(s.desop2)
	-- 注册在战斗阶段结束时将自身破坏的延迟效果。
	Duel.RegisterEffect(de,tp)
end
-- 战斗阶段结束时，检查此卡是否带有对应标记，若有则将其破坏。
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=e:GetLabel()
	if tc:GetFlagEffectLabel(id)==fid then
		-- 因效果破坏这张卡自身。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
