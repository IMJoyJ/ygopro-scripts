--旋壊のヴェスペネイト
-- 效果：
-- 5星怪兽×2
-- 「旋坏之贯破黄蜂巢」1回合1次也能在自己场上的4阶超量怪兽上面重叠来超量召唤。这张卡在超量召唤的回合不能作为超量召唤的素材。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：超量召唤的这张卡被对方破坏的场合，以自己墓地1只5星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
function c39317553.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,2,c39317553.ovfilter,aux.Stringid(39317553,0),2,c39317553.xyzop)  --"是否在4阶超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡在超量召唤的回合不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetCondition(c39317553.xyzcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：超量召唤的这张卡被对方破坏的场合，以自己墓地1只5星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39317553,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,39317553)
	e3:SetCondition(c39317553.spcon)
	e3:SetTarget(c39317553.sptg)
	e3:SetOperation(c39317553.spop)
	c:RegisterEffect(e3)
end
-- 检查候选怪兽是否为表侧表示的4阶超量怪兽，用于“在自己场上的4阶超量怪兽上面重叠来超量召唤”的叠放条件。
function c39317553.ovfilter(c)
	return c:IsFaceup() and c:IsRank(4)
end
-- 该函数作为超量召唤手续的附加操作：在执行叠放前检查本方玩家本回合是否已使用过该叠放方式（Flag为0才可用）；若可用，则在玩家身上注册一个结束阶段重置的誓约标记，使本回合不能再重复使用该方式。
function c39317553.xyzop(e,tp,chk)
	-- 在合法性检查阶段，确认本方玩家本回合尚未使用过这个“1回合1次”的叠放方式（没有对应的Flag标识），若未使用则返回true允许处理。
	if chk==0 then return Duel.GetFlagEffect(tp,39317553)==0 end
	-- 注册一个持续到结束阶段的誓约标记，记录本方玩家本回合已使用了“在4阶超量怪兽上面叠放”的超量召唤方式，用于阻止本回合再次使用。
	Duel.RegisterFlagEffect(tp,39317553,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断此卡是否处于“本回合超量召唤”状态（有超量召唤成功后的特殊召唤状态且召唤类型为超量召唤），作为“不能作为超量召唤素材”效果的适用条件。
function c39317553.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- ②效果的发动条件：这张卡是以超量召唤方式出场，且被对方（rp==1-tp）的效果/攻击破坏，并且破坏前控制权属于自己、位于我方怪兽区。
function c39317553.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选墓地中可作为②效果对象的怪兽：5星以下，并且能够被当前效果特殊召唤（满足特殊召唤条件/苏生限制）。
function c39317553.spfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标处理：若指定了对象则验证其在墓地且属于自己且仍满足条件；在发动时需确认自己场上有空余怪兽区，并且墓地存在至少1只符合条件的怪兽。
function c39317553.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39317553.spfilter(chkc,e,tp) end
	-- ②效果的发动条件：自己场上留有可用怪兽区，以便特殊召唤对象怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- ②效果的发动条件：墓地中至少存在1只满足条件、可作为对象的5星以下怪兽。
		and Duel.IsExistingTarget(c39317553.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示，引导玩家选择墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的5星以下怪兽，并将其设置为当前连锁的二效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,c39317553.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记这次效果处理的操作信息：将从墓地选择的那1只怪兽进行特殊召唤（对象g，数量1，来源墓地），供后续处理及连锁查询使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
-- ②效果实际处理：确认空位后，取得对象卡；只要对象仍然与效果有关联，就将其以表侧攻击表示特殊召唤到自己的怪兽区。
function c39317553.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查：若自己场上没有可用怪兽区，则直接终止处理。
	if Duel.GetMZoneCount(tp)<1 then return end
	-- 获取当前连锁的②效果所选择的墓地对象怪兽。
	local c=Duel.GetFirstTarget()
	if c and c:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，完成“那只怪兽特殊召唤”的处理。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
