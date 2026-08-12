--ミュートリア超個体系
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只4星以下的「秘异三变」怪兽加入手卡或特殊召唤。
-- ②：自己场上的8星以上的「秘异三变」怪兽被效果破坏的场合，可以作为代替把场上的这张卡除外。
function c60967717.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只4星以下的「秘异三变」怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,60967717+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetOperation(c60967717.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的8星以上的「秘异三变」怪兽被效果破坏的场合，可以作为代替把场上的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c60967717.reptg)
	e2:SetValue(c60967717.repval)
	e2:SetOperation(c60967717.repop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中属于「秘异三变」且等级在4星以下，并满足加入手卡或特殊召唤条件的怪兽
function c60967717.filter(c,e,tp,ft)
	return c:IsSetCard(0x157) and c:IsLevelBelow(4)
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 作为这张卡发动时的效果处理，玩家可选择是否从卡组将1只4星以下的「秘异三变」怪兽加入手卡或特殊召唤
function c60967717.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 从卡组中获取满足条件的「秘异三变」怪兽组
	local g=Duel.GetMatchingGroup(c60967717.filter,tp,LOCATION_DECK,0,nil,e,tp,ft)
	-- 若卡组中存在符合条件的怪兽，则询问玩家是否选择发动该效果
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(60967717,0)) then  --"是否要从卡组把怪兽加入手卡或特殊召唤？"
		-- 提示玩家选择要操作的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		local opt=0
		if not tc:IsAbleToHand() then
			opt=1
		elseif not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 then
			opt=0
		else
			-- 让玩家选择将卡片加入手卡或特殊召唤
			opt=Duel.SelectOption(tp,1190,1152)
		end
		if opt==0 then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤自己场上因效果预定被破坏的表侧表示的8星以上的「秘异三变」怪兽
function c60967717.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x157) and c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(8)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断此卡是否能被除外，并确认是否有符合条件的怪兽预定被效果破坏
function c60967717.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c60967717.repfilter,1,nil,tp) end
	-- 询问玩家是否适用代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 指定代替破坏效果适用的对象
function c60967717.repval(e,c)
	return c60967717.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏的处理，将场上的这张卡除外
function c60967717.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将场上的这张卡表侧表示除外，作为代替破坏的处理
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
