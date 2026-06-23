--ワイト・マスター
-- 效果：
-- ①：自己的「白骨王」向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，以自己墓地1只「白骨」或「白骨王」为对象才能发动。把1只「白骨」或者有那个卡名记述的怪兽从卡组送去墓地，作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的激活效果、贯穿伤害效果和特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡具有「白骨」和「白骨王」的卡号信息
	aux.AddCodeList(c,32274490,36021814)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「白骨王」向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.pietg)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己墓地1只「白骨」或「白骨王」为对象才能发动。把1只「白骨」或者有那个卡名记述的怪兽从卡组送去墓地，作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 设置贯穿伤害效果的目标为「白骨王」
function s.pietg(e,c)
	return c:IsCode(36021814)
end
-- 过滤函数，用于检索卡组中可以送去墓地的「白骨」或「白骨王」怪兽
function s.tgfilter(c)
	-- 检索满足条件的「白骨」或「白骨王」怪兽
	return aux.IsCodeOrListed(c,32274490) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤函数，用于检索墓地中可以特殊召唤的「白骨」或「白骨王」怪兽
function s.spfilter(c,e,tp)
	return c:IsCode(32274490,36021814) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件，检查是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查卡组中是否存在可送去墓地的「白骨」或「白骨王」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在可特殊召唤的「白骨」或「白骨王」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中要特殊召唤的怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，指定要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果操作信息，指定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果的操作流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择卡组中要送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 将选中的卡送去墓地
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE)
			-- 确认目标怪兽满足特殊召唤条件
			and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and aux.NecroValleyFilter()(tc) then
			-- 将目标怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置发动后直到回合结束时自己不能特殊召唤非不死族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤的条件为非不死族怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
