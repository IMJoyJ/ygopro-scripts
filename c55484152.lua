--燦幻封炉
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己的龙族·炎属性怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。那只怪兽在自己场上守备表示特殊召唤。
-- ②：对方结束阶段，支付1000基本分，以自己墓地1张「灿幻」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔陷发动效果、①效果（战斗破坏怪兽时特召）和②效果（对方结束阶段支付1000LP盖放墓地「灿幻」魔陷）。
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
-- ①效果的发动条件判定：检查进行战斗的怪兽是否是自己场上的龙族·炎属性怪兽（若已离场则检查其在场上的最后状态）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取由自己操控的、正处于战斗中的怪兽。
	local a=Duel.GetBattleMonster(tp)
	return a and (a:IsLocation(LOCATION_MZONE) and a:IsRace(RACE_DRAGON) and a:IsAttribute(ATTRIBUTE_FIRE)
		or not a:IsLocation(LOCATION_MZONE) and a:IsPreviousControler(tp)
			and a:GetPreviousRaceOnField()&RACE_DRAGON~=0
			and a:GetPreviousAttributeOnField()&ATTRIBUTE_FIRE~=0)
end
-- 过滤被战斗破坏的怪兽：不能是衍生物、在墓地/除外状态（非场上）、是怪兽卡、可以成为效果对象，且可以以守备表示特殊召唤。
function s.tgfilter(c,e,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动目标选择与操作信息设置：检查自己场上是否有怪兽区域空位，并从被破坏的怪兽中选择1只作为效果对象，设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.tgfilter,nil,e,tp)
	-- 检查发动的基本条件：自己场上必须有空余的怪兽区域，且被破坏的怪兽中存在符合特召条件的卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 end
	local bc=g:GetFirst()
	if g:GetCount()>1 then
		bc=g:FilterSelect(tp,s.tgfilter,1,1,nil,e,tp):GetFirst()
	end
	-- 将选中的被破坏怪兽设为当前连锁的效果对象。
	Duel.SetTargetCard(bc)
	-- 设置特殊召唤的操作信息，包含特殊召唤的卡片对象和数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- ①效果的效果处理：获取效果对象，在不受王家长眠之谷影响的情况下，将该怪兽在自己场上表侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象（即被破坏的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查效果对象是否仍与当前效果相关联，且不受王家长眠之谷的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽在自己场上以表侧守备表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件判定：检查当前是否为对方的回合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方玩家。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的Cost支付判定与执行：检查并支付1000点基本分。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够支付1000点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除自己1000点基本分作为发动的代价。
	Duel.PayLPCost(tp,1000)
end
-- 过滤墓地中的卡片：属于「灿幻」系列、是魔法或陷阱卡，且可以在场上盖放。
function s.sfilter(c)
	return c:IsSetCard(0x1a9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动目标选择与操作信息设置：选择自己墓地1张「灿幻」魔法·陷阱卡作为效果对象，并设置离开墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的「灿幻」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家选择自己墓地中1张符合条件的「灿幻」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置离开墓地的操作信息，包含目标卡片和数量。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的效果处理：获取效果对象，在不受王家长眠之谷影响的情况下将其在自己场上盖放，并添加“从场上离开的场合除外”的限制。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象（即墓地的「灿幻」魔陷）。
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡片是否仍与当前效果相关联，且不受王家长眠之谷的影响，并成功将其在自己场上盖放。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc) then
		-- 这个效果盖放的卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1)
	end
end
