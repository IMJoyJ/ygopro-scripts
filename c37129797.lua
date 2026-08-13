--ヴァンパイア・サッカー
-- 效果：
-- 不死族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。这个效果特殊召唤的怪兽变成不死族。
-- ②：从自己·对方的墓地有不死族怪兽特殊召唤的场合发动。自己抽1张。
-- ③：自己把怪兽上级召唤的场合，可以作为自己场上的怪兽的代替而把对方场上的不死族怪兽解放。
function c37129797.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：素材为2只不死族怪兽（对应“不死族怪兽2只”）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。这个效果特殊召唤的怪兽变成不死族。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37129797,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,37129797)
	e1:SetTarget(c37129797.sptg)
	e1:SetOperation(c37129797.spop)
	c:RegisterEffect(e1)
	-- ②：从自己·对方的墓地有不死族怪兽特殊召唤的场合发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37129797,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,37129798)
	e2:SetCondition(c37129797.drcon)
	e2:SetTarget(c37129797.drtg)
	e2:SetOperation(c37129797.drop)
	c:RegisterEffect(e2)
	-- ③：自己把怪兽上级召唤的场合，可以作为自己场上的怪兽的代替而把对方场上的不死族怪兽解放。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c37129797.exrtg)
	e3:SetValue(POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	-- ③：自己把怪兽上级召唤的场合，可以作为自己场上的怪兽的代替而把对方场上的不死族怪兽解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	-- 设置e4的生效目标为手卡中的怪兽卡（仅手卡怪兽可获得e3效果）。
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查怪兽是否能被效果以表侧守备表示特殊召唤到对方场上（满足苏生限制及特殊召唤条件）。
function c37129797.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- ①效果的目标选择与发动判定：检查对方墓地是否存在1只可特殊召唤的怪兽，且对方场上有空余怪兽区；发动时选择该怪兽作为对象。
function c37129797.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c37129797.spfilter(chkc,e,tp) end
	-- 检查对方场上有无空余怪兽区（以自己视角计算对方场上的可用区域），供特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检查对方墓地是否存在至少1只满足特殊召唤条件的怪兽，作为效果对象候选。
		and Duel.IsExistingTarget(c37129797.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家发送选择提示消息，提示选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只满足条件的怪兽，将其登记为本连锁的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c37129797.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：此效果将进行1次特殊召唤，对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽特殊召唤到对方场上守备表示；成功后赋予该怪兽种族变为不死族的效果，最后完成特殊召唤流程。
function c37129797.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的效果对象卡（此前选择的对方墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过SpecialSummonStep将对象怪兽以表侧守备表示特殊召唤到对方场上；若特殊召唤成功，则执行后续变种族处理。
		if Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这个效果特殊召唤的怪兽变成不死族。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_ZOMBIE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成所有特殊召唤步骤，正式宣告特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
end
-- 过滤函数：判断怪兽是否为不死族，且特殊召唤前位于墓地（即从墓地特殊召唤）。
function c37129797.drfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- ②诱发条件：本次特殊召唤成功的怪兽组中存在除本卡以外的不死族怪兽，且该怪兽是从墓地特殊召唤的。
function c37129797.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37129797.drfilter,1,e:GetHandler())
end
-- ②效果的目标设置：登记抽卡玩家为自己、抽卡数量为1，并设置操作信息为抽卡效果。
function c37129797.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果处理时的目标玩家设置为自己（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将效果参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记操作信息：此效果将令tp玩家抽1张卡（分类为抽卡效果）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：按照登记的目标玩家和数量执行抽卡（自己抽1张）。
function c37129797.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的目标玩家和参数（抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽取d张卡，抽卡原因为效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ③的解放替代判定：将对方场上的表侧表示不死族怪兽作为额外的上级召唤解放素材（可代替己方怪兽解放）。
function c37129797.exrtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
