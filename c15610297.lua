--方界胤ヴィジャム
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。怪兽区域的这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，给那只对方怪兽放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
-- ③：这张卡的效果让这张卡当作永续魔法卡使用的场合，自己主要阶段才能发动。魔法与陷阱区域的这张卡特殊召唤。
function c15610297.initial_effect(c)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。怪兽区域的这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，给那只对方怪兽放置 1 个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15610297,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetTarget(c15610297.distg)
	e2:SetOperation(c15610297.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡的效果让这张卡当作永续魔法卡使用的场合，自己主要阶段才能发动。魔法与陷阱区域的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15610297,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c15610297.spcon)
	e3:SetTarget(c15610297.sptg)
	e3:SetOperation(c15610297.spop)
	c:RegisterEffect(e3)
end
c15610297.mentioned_counter={
	[0x1038]=true,
}
-- 效果处理：定义触发效果的发动条件检查函数 distg，确认对方怪兽在场正面、可加指示物、自身在怪兽区且与战斗相关以及魔法陷阱区域有空位。
function c15610297.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsCanAddCounter(0x1038,1)
		and c:IsLocation(LOCATION_MZONE) and c:IsRelateToBattle()
		-- 条件检查：确认魔法与陷阱区域是否有空位，用于移动卡片位置至魔陷区。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果处理：定义触发效果的发动操作函数 disop，将怪兽移至魔法陷阱区并改变种类为永续魔法卡，记录标志位，给对手怪兽放置指示物并赋予不能攻击及无效化效果。
function c15610297.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsLocation(LOCATION_MZONE) then return end
	-- 操作检查：确认将卡片移动到魔法陷阱区域是否成功，失败则返回结束处理流程。
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	-- ②中“怪兽区域的这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置”对应的类型改变逻辑实现。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(15610297,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		bc:AddCounter(0x1038,1)
		-- ②中“有方界指示物放置的怪兽不能攻击，效果无效化。”对应的逻辑实现及条件检查函数定义。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(c15610297.condition)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		bc:RegisterEffect(e2)
	end
end
-- 条件检查：确认对方怪兽身上的方界指示物数量是否大于零，以此决定是否生效不能攻击效果。
function c15610297.condition(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
-- 发动条件：确认卡片在魔法陷阱区域时身上是否有对应的标志位效果（即已执行过怪兽区转魔陷区的转换）。
function c15610297.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(15610297)~=0
end
-- 发动目标检查：定义特殊召唤的目标选择函数 sptg，初步确认主要怪兽区和卡片苏生能力。
function c15610297.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查：确认主要怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 操作信息设置：为后续的特殊召唤效果处理确定分类和对象数量（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③中“魔法与陷阱区域的这张卡特殊召唤。”对应的操作函数定义及执行逻辑。
function c15610297.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 效果处理：将卡片从魔法陷阱区域特殊召唤回主要怪兽区（正面表示）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
