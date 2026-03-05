--覇王門の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：自己场上的「霸王龙 扎克」不能用对方的效果除外。
-- ②：自己主要阶段才能发动。这张卡破坏，从手卡·卡组把「霸王门之魔术师」以外的1只「霸王门」灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己的灵摆区域有「霸王门之魔术师」以外的「霸王门」卡存在的场合才能发动。从手卡·额外卡组把「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽之内1只送去墓地，这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。除魔法师族怪兽外的1张有「霸王龙 扎克」的卡名记述的卡从卡组加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名代码列表、灵摆属性，并创建4个效果
function s.initial_effect(c)
	-- 记录该卡拥有「霸王龙 扎克」的卡名
	aux.AddCodeList(c,13331639)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「霸王龙 扎克」不能用对方的效果除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.rmlimit)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。这张卡破坏，从手卡·卡组把「霸王门之魔术师」以外的1只「霸王门」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	-- ①：自己的灵摆区域有「霸王门之魔术师」以外的「霸王门」卡存在的场合才能发动。从手卡·额外卡组把「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽之内1只送去墓地，这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ②：这张卡特殊召唤的场合才能发动。除魔法师族怪兽外的1张有「霸王龙 扎克」的卡名记述的卡从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 限制「霸王龙 扎克」被对方效果除外
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsOnField() and c:IsCode(13331639) and c:IsFaceup()
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- 灵摆区域放置卡的过滤函数
function s.penfilter(c)
	return c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM) and not c:IsCode(id) and not c:IsForbidden()
end
-- 灵摆区域放置效果的发动条件判断
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 灵摆区域放置效果的发动条件判断
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 设置灵摆区域放置效果的处理信息为破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆区域放置效果的处理函数
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏自身
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 选择要放置到场上的卡
		local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡放置到灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- 特殊召唤条件中灵摆区域卡的过滤函数
function s.spfilter(c)
	return c:IsSetCard(0x10f8) and not c:IsCode(id)
end
-- 特殊召唤效果的发动条件判断
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤效果的发动条件判断
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 特殊召唤时需要送墓的卡的过滤函数
function s.spfilter2(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 特殊召唤效果的发动条件判断
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 特殊召唤效果的发动条件判断
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 特殊召唤效果的发动条件判断
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	-- 设置特殊召唤效果的处理信息为送墓
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	-- 设置特殊召唤效果的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	local gc=g:GetFirst()
	-- 将选中的卡送去墓地并判断是否成功
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将自身特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 检索效果中卡的过滤函数
function s.thfilter(c)
	-- 检索效果中卡的过滤函数
	return aux.IsCodeListed(c,13331639) and not c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 检索效果的发动条件判断
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索效果的发动条件判断
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息为加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
