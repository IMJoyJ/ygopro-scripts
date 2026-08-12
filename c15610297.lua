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
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。怪兽区域的这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，给那只对方怪兽放置1个方界指示物。有方界指示物放置的怪兽不能攻击，效果无效化。
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
-- 效果发动条件判定：确认进行战斗的对方怪兽为表侧表示、仍与战斗相关且可以放置方界指示物，这张卡在怪兽区域存在且仍与战斗相关，并且自己魔法与陷阱区域有空位
function c15610297.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsCanAddCounter(0x1038,1)
		and c:IsLocation(LOCATION_MZONE) and c:IsRelateToBattle()
		-- 确认自己的魔法与陷阱区域有可以使用的空格子
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果处理：确认这张卡仍与此效果相关、不受此效果影响且仍在怪兽区域后，将其移动到魔法与陷阱区域，变为永续魔法卡并登记标记，再给那只对方怪兽放置1个方界指示物并使其不能攻击、效果无效化
function c15610297.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsLocation(LOCATION_MZONE) then return end
	-- 把这张卡以表侧表示移动到自己的魔法与陷阱区域放置，移动失败则中断效果处理
	if not Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	-- 怪兽区域的这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置
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
		-- 有方界指示物放置的怪兽不能攻击
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
-- 条件判定：对象怪兽上放置有方界指示物（数量大于0）时该限制才适用
function c15610297.condition(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
-- 发动条件判定：这张卡是因这张卡的效果当作永续魔法卡使用（带有本卡效果登记的标记）的场合才能发动
function c15610297.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(15610297)~=0
end
-- 效果发动条件判定：确认自己的主要怪兽区域有空位，且魔法与陷阱区域的这张卡可以被特殊召唤
function c15610297.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域有可以使用的空格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预告本连锁将把自己场上魔法与陷阱区域的这张卡1张特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：确认这张卡仍与此效果相关后，将其从魔法与陷阱区域表侧攻击表示特殊召唤到主要怪兽区域
function c15610297.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 把这张卡从魔法与陷阱区域以表侧表示特殊召唤到自己的主要怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
