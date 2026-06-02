--プランキッズ・ドロップ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己回复1000基本分。那之后，可以从手卡·卡组把「调皮宝贝·水滴娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c55725117.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己回复1000基本分。那之后，可以从手卡·卡组把「调皮宝贝·水滴娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,55725117)
	e1:SetCondition(c55725117.reccon)
	e1:SetTarget(c55725117.rectg)
	e1:SetOperation(c55725117.recop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否作为「调皮宝贝」怪兽的融合或连接素材送去墓地
function c55725117.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&(REASON_FUSION+REASON_LINK)~=0 and not c:IsReason(REASON_RETURN)
end
-- 效果发动的对象与操作信息设置（回复1000基本分）
function c55725117.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1000（回复数值）
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为回复自己1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 过滤手卡·卡组中除「调皮宝贝·水滴娃」以外的、可以表侧守备表示特殊召唤的「调皮宝贝」怪兽
function c55725117.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(55725117)
end
-- 效果处理：自己回复1000基本分，之后可以从手卡·卡组将1只「调皮宝贝·水滴娃」以外的「调皮宝贝」怪兽守备表示特殊召唤
function c55725117.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取手卡·卡组中满足特殊召唤条件的「调皮宝贝」怪兽
	local g=Duel.GetMatchingGroup(c55725117.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 执行回复基本分，若回复成功且有可特召的怪兽和空怪兽区域，则询问玩家是否进行特殊召唤
	if Duel.Recover(p,d,REASON_EFFECT)~=0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(55725117,0)) then  --"是否特殊召唤？"
		-- 中断当前效果，使后续的特殊召唤处理与回复基本分不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
