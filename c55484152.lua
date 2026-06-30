--燦幻封炉
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己的龙族·炎属性怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
-- ②：对方结束阶段，支付1000基本分，以自己墓地1张「灿幻」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册该卡作为永续魔法卡的发动效果，以及其①的被战斗破坏怪兽特召效果和②的对方结束阶段盖放墓地魔法/陷阱卡的效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己的龙族·炎属性怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方结束阶段，支付1000基本分，以自己墓地1张「灿幻」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：检查自己参与战斗的怪兽是否在场，并确认其在场上或离场前的状态是自己控制的龙族·炎属性怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己控制的参与战斗的怪兽。
	local a=Duel.GetBattleMonster(tp)
	return a and (a:IsLocation(LOCATION_MZONE) and a:IsRace(RACE_DRAGON) and a:IsAttribute(ATTRIBUTE_FIRE)
		or not a:IsLocation(LOCATION_MZONE) and a:IsPreviousControler(tp)
			and a:GetPreviousRaceOnField()&RACE_DRAGON~=0
			and a:GetPreviousAttributeOnField()&ATTRIBUTE_FIRE~=0)
end
-- 过滤可成为特召目标的对象卡：非衍生物的怪兽卡，且能成为效果对象、能在自己场上守备表示特殊召唤。
function s.tgfilter(c,e,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备与目标选择：检查是否能特殊召唤以及是否存在符合条件的被破坏怪兽，若符合则选择其中1只作为效果的对象，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.tgfilter,nil,e,tp)
	-- 发动的可行性检查：检查自己场上是否有空闲的怪兽区域，以及本次战斗中被破坏的怪兽是否包含符合特召条件的卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 end
	local bc=g:GetFirst()
	if g:GetCount()>1 then
		bc=g:FilterSelect(tp,s.tgfilter,1,1,nil,e,tp):GetFirst()
	end
	-- 将选定的目标怪兽设置为当前效果的连锁对象。
	Duel.SetTargetCard(bc)
	-- 设置特殊召唤的操作信息：预计将该目标怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- ①效果的确定处理：获取作为效果对象的目标怪兽，若其仍与此效果关联且不受「王家长眠之谷」影响，则在自己场上守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的连锁对象（即要特殊召唤的目标怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽在效果处理时是否仍与此效果相关联，并且其不受「王家长眠之谷」的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件：检查当前回合是否为对方的回合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前的回合玩家是否是对方玩家。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的消耗支付：在发动时，检查自己是否能支付1000基本分，并支付1000基本分。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：检查自己当前是否能支付1000点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除自己1000点基本分作为效果发动的代价。
	Duel.PayLPCost(tp,1000)
end
-- 过滤符合条件的墓地卡片：属于「灿幻」系列的魔法·陷阱卡，且当前能盖放到场上。
function s.sfilter(c)
	return c:IsSetCard(0x1a9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动准备与目标选择：检查自己墓地中是否有符合条件的「灿幻」魔法·陷阱卡作为效果的对象，并设置该卡离开墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc) end
	-- 发动的可行性检查：确认自己墓地中是否存在至少1张符合条件的「灿幻」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示当前玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地中1张符合条件的「灿幻」魔法·陷阱卡设置为效果的连锁对象。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果分类与操作信息：当前效果包含使所选择的目标卡片离开墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的确定处理：获取作为效果对象的目标卡片，在不受「王家长眠之谷」影响的情况下将其成功盖放到自己场上，并为其添加从场上离开时除外的除外效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的连锁对象（即要盖放的墓地目标卡片）。
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡片在处理时仍与此效果相关联、不受「王家长眠之谷」影响，并且成功在自己场上盖放。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc)>0 then
		-- 这个效果盖放的卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1)
	end
end
