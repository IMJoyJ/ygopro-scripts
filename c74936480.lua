--ダイノルフィア・ステルスベギア
-- 效果：
-- 卡名不同的「恐啡肽狂龙」怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己基本分是2000以下，自己为让「恐啡肽狂龙」怪兽的效果以及陷阱卡发动而支付的基本分变成不需要。
-- ②：对方把怪兽的效果发动时才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地选1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
function c74936480.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只满足过滤条件（卡名不同且属于「恐啡肽狂龙」系列）的怪兽作为素材。
	aux.AddFusionProcFunRep(c,c74936480.ffilter,2,true)
	-- ①：只要自己基本分是2000以下，自己为让「恐啡肽狂龙」怪兽的效果以及陷阱卡发动而支付的基本分变成不需要。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_LPCOST_CHANGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c74936480.costchange)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,74936480)
	e2:SetCondition(c74936480.damcon)
	e2:SetTarget(c74936480.damtg)
	e2:SetOperation(c74936480.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地选1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,74936481)
	e3:SetCondition(c74936480.spcon)
	e3:SetTarget(c74936480.sptg)
	e3:SetOperation(c74936480.spop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：属于「恐啡肽狂龙」系列，且融合素材中不能存在同名卡。
function c74936480.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x173) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 改变支付基本分代价的价值函数：若满足条件则将所需支付的基本分变为0。
function c74936480.costchange(e,re,rp,val)
	-- 检查自己当前基本分是否在2000以下，且存在正在发动的效果。
	if Duel.GetLP(e:GetHandlerPlayer())<=2000 and re
		and (re:GetHandler():IsSetCard(0x173) and re:IsActiveType(TYPE_MONSTER)
			or re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_TRAP)) then
		return 0
	else return val end
end
-- 伤害效果的发动条件：对方发动了怪兽的效果。
function c74936480.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and re:IsActiveType(TYPE_MONSTER)
end
-- 伤害效果的启动与目标确认：检查发动效果的怪兽原本攻击力是否大于0，并设置给与对方伤害的操作信息。
function c74936480.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local atk=rc:GetBaseAttack()
	if chk==0 then return atk>0 end
	-- 设置连锁处理的操作信息，分类为伤害，对象为对方玩家，数值为该怪兽的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 伤害效果的执行：给与对方该怪兽原本攻击力数值的伤害。
function c74936480.damop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local atk=rc:GetBaseAttack()
	-- 因效果给与对方玩家等同于该怪兽原本攻击力数值的伤害。
	Duel.Damage(1-tp,atk,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件：此卡被战斗或效果破坏。
function c74936480.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤目标的过滤条件：墓地中4星以下的「恐啡肽狂龙」怪兽，且能被特殊召唤。
function c74936480.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的启动与目标确认：检查自己场上是否有空位，以及墓地是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function c74936480.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c74936480.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，分类为特殊召唤，数量为1，位置为自己墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的执行：从自己墓地选择1只符合条件的怪兽特殊召唤到场上。
function c74936480.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c74936480.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
