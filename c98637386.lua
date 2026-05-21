--ゴヨウ・プレデター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「御用捕食者」的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽给与玩家的战斗伤害变成一半。
function c98637386.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 「御用捕食者」的效果1回合只能使用1次。①：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽给与玩家的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98637386,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1,98637386)
	-- 设置发动条件为：自身战斗破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c98637386.sptg)
	e1:SetOperation(c98637386.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与可行性检测：获取被战斗破坏的怪兽，并确认自己场上有空位且该怪兽可以被特殊召唤
function c98637386.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 在发动时检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将被战斗破坏的怪兽设为效果处理的对象
	Duel.SetTargetCard(bc)
	-- 设置连锁的操作信息为：特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果处理：将作为对象的怪兽在自己场上特殊召唤，并使其给与玩家的战斗伤害变成一半
function c98637386.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽以表侧表示特殊召唤到自己场上
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽给与玩家的战斗伤害变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e1:SetValue(HALF_DAMAGE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
