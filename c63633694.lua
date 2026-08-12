--機巧蹄－天迦久御雷
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：额外怪兽区域有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：以额外怪兽区域1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
-- ③：这张卡战斗破坏对方怪兽时才能发动。选给这张卡装备的1张自己的怪兽卡特殊召唤。
function c63633694.initial_effect(c)
	-- ①：额外怪兽区域有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63633694,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63633694)
	e1:SetCondition(c63633694.spcon1)
	e1:SetTarget(c63633694.sptg1)
	e1:SetOperation(c63633694.spop1)
	c:RegisterEffect(e1)
	-- ②：以额外怪兽区域1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备（只有1只可以装备）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63633694,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,63633695)
	e2:SetCondition(c63633694.eqcon)
	e2:SetTarget(c63633694.eqtg)
	e2:SetOperation(c63633694.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽时才能发动。选给这张卡装备的1张自己的怪兽卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63633694,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,63633696)
	-- 设置效果3的发动条件为这张卡战斗破坏对方怪兽时。
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c63633694.sptg2)
	e3:SetOperation(c63633694.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否在额外怪兽区域。
function c63633694.cfilter(c)
	return c:GetSequence()>4
end
-- 效果1的发动条件：额外怪兽区域有怪兽存在。
function c63633694.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上的额外怪兽区域是否存在至少1只怪兽。
	return Duel.GetMatchingGroupCount(c63633694.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>0
end
-- 效果1的靶向与发动准备：检查自身是否能特殊召唤并设置特殊召唤的操作信息。
function c63633694.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果1的运行处理：将手牌中的这张卡特殊召唤。
function c63633694.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断是否为额外怪兽区域的表侧表示怪兽，且可以被自己控制或转移控制权。
function c63633694.eqfilter(c,tp)
	return c:IsFaceup() and c:GetSequence()>4 and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- 效果2的发动条件：这张卡当前没有通过该效果装备怪兽（限制只能装备1只）。
function c63633694.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(63633694)==0
end
-- 效果2的靶向与发动准备：选择额外怪兽区域的1只表侧表示怪兽作为对象。
function c63633694.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63633694.eqfilter(chkc,tp) end
	-- 检查自己场上是否有空余的魔法与陷阱区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查双方场上的额外怪兽区域是否存在可以作为对象的表侧表示怪兽。
		and Duel.IsExistingTarget(c63633694.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择额外怪兽区域的1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c63633694.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- 效果2的运行处理：将选择的对象怪兽作为装备卡装备给这张卡，并添加装备限制。
function c63633694.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的发动对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(63633694,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 当作装备卡使用给这张卡装备（只有1只可以装备）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c63633694.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制函数：该装备卡只能装备给这张卡（效果来源卡）。
function c63633694.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤函数：判断卡片是否为装备在自己身上的怪兽卡，且可以被特殊召唤。
function c63633694.spfilter(c,e,tp)
	return c:GetEquipTarget()==e:GetHandler() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果3的靶向与发动准备：检查自己场上是否有空余怪兽区域，以及是否存在可特殊召唤的装备怪兽。
function c63633694.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的魔法与陷阱区域是否存在装备在这张卡上的怪兽卡。
		and Duel.IsExistingMatchingCard(c63633694.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从魔法与陷阱区域特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
-- 效果3的运行处理：选择1张装备在这张卡上的怪兽卡特殊召唤。
function c63633694.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1张装备在这张卡上的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c63633694.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽卡特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
