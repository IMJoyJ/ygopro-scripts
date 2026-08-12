--光翼の竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段才能发动。从卡组把1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽加入手卡。自己场上有「霸王龙 扎克」存在的场合，也能不加入手卡特殊召唤。
function c82190203.initial_effect(c)
	-- 建立与卡片密码13331639（霸王龙 扎克）的关联信息
	aux.AddCodeList(c,13331639)
	-- ①：自己·对方的主要阶段才能发动。从卡组把1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽加入手卡。自己场上有「霸王龙 扎克」存在的场合，也能不加入手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,82190203+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c82190203.condition)
	e1:SetTarget(c82190203.target)
	e1:SetOperation(c82190203.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数
function c82190203.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：场上表侧表示的「霸王龙 扎克」
function c82190203.cfilter(c)
	return c:IsCode(13331639) and c:IsFaceup()
end
-- 过滤条件：卡组中可以加入手卡，或者在满足特殊召唤条件时可以特殊召唤的「霸王眷龙」或「霸王门」灵摆怪兽
function c82190203.filter(c,e,tp,check)
	return c:IsSetCard(0x10f8,0x20f8) and c:IsType(TYPE_PENDULUM) and (c:IsAbleToHand()
		or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 定义效果发动时的目标选择与合法性检测函数
function c82190203.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有空余的怪兽区域
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己场上是否存在表侧表示的「霸王龙 扎克」
			and Duel.IsExistingMatchingCard(c82190203.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查卡组中是否存在至少1张满足条件的「霸王眷龙」或「霸王门」灵摆怪兽
		return Duel.IsExistingMatchingCard(c82190203.filter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 定义效果处理函数
function c82190203.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，检查自己场上是否有空余的怪兽区域
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果处理时，检查自己场上是否存在表侧表示的「霸王龙 扎克」
		and Duel.IsExistingMatchingCard(c82190203.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1张满足条件的「霸王眷龙」或「霸王门」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c82190203.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	local b=check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 如果该卡可以加入手卡，且（不能特殊召唤或玩家选择「加入手卡」选项），则准备加入手卡
	if tc:IsAbleToHand() and (not b or Duel.SelectOption(tp,1190,1152)==0) then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
