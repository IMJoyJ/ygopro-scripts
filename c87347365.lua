--リバイバルゴーレム
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从卡组送去墓地的场合，从以下效果选择1个发动。
-- ●这张卡特殊召唤。
-- ●这张卡加入手卡。
function c87347365.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡从卡组送去墓地的场合，从以下效果选择1个发动。●这张卡特殊召唤。●这张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87347365,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,87347365)
	e1:SetCondition(c87347365.condtion)
	e1:SetTarget(c87347365.target)
	e1:SetOperation(c87347365.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查这张卡是否是从卡组送去墓地
function c87347365.condtion(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 效果发动时的处理：检测可选择的选项，由玩家选择其中一个效果发动，并设置对应的效果分类与操作信息
function c87347365.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local opt=0
	local c=e:GetHandler()
	-- 检查自身是否可以特殊召唤，且自己场上是否有可用的怪兽区域空格
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=c:IsAbleToHand()
	if b1 and b2 then
		-- 若两个效果均可发动，则由玩家选择“特殊召唤”或“加入手卡”
		opt=Duel.SelectOption(tp,aux.Stringid(87347365,1),aux.Stringid(87347365,2))+1  --"这张卡特殊召唤/这张卡加入手卡"
	elseif b1 then
		-- 若只能特殊召唤，则玩家只能选择“特殊召唤”
		opt=Duel.SelectOption(tp,aux.Stringid(87347365,1))+1  --"这张卡特殊召唤"
	elseif b2 then
		-- 若只能加入手卡，则玩家只能选择“加入手卡”
		opt=Duel.SelectOption(tp,aux.Stringid(87347365,2))+2  --"这张卡加入手卡"
	end
	e:SetLabel(opt)
	if opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：将自身特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif opt==2 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置操作信息：将自身加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	else
		e:SetCategory(0)
	end
end
-- 效果处理：根据发动时选择的选项，将自身特殊召唤或加入手卡
function c87347365.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		if c:IsRelateToEffect(e) then
			-- 将自身以表侧表示特殊召唤
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		if c:IsRelateToEffect(e) then
			-- 将自身加入手卡
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的这张卡
			Duel.ConfirmCards(1-tp,c)
		end
	end
end
