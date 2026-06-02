--プランキッズ・ドロップ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己回复1000基本分。那之后，可以从手卡·卡组把「调皮宝贝·水滴娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c55725117.initial_effect(c)
	-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己回复1000基本分。那之后，可以从手卡·卡组把「调皮宝贝·水滴娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。这个卡名的效果1回合只能使用1次。
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
-- 效果①的发动条件：这张卡在墓地，且作为「调皮宝贝」怪兽的融合素材或连接素材送去墓地
function c55725117.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&(REASON_FUSION+REASON_LINK)~=0 and not c:IsReason(REASON_RETURN)
end
-- 效果①的发动准备：设置回复效果的对象玩家与回复数值，并设置生命值回复的操作信息
function c55725117.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将回复效果的对象玩家设置为自己（效果的发动者）
	Duel.SetTargetPlayer(tp)
	-- 设置回复的基本分数值为1000
	Duel.SetTargetParam(1000)
	-- 设置当前效果处理的操作信息为使玩家自身回复1000点生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 过滤条件：手卡·卡组中除了「调皮宝贝·水滴娃」以外可以被特殊召唤的「调皮宝贝」怪兽
function c55725117.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(55725117)
end
-- 效果①的效果处理：玩家自身回复1000点基本分，若成功且怪兽区域有空位，可以从手卡或卡组选择1只符合条件的怪兽守备表示特殊召唤
function c55725117.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的回复对象玩家与回复的基本分数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取玩家自身手牌和卡组中符合特殊召唤条件的「调皮宝贝」怪兽
	local g=Duel.GetMatchingGroup(c55725117.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 进行回复生命值处理，在成功回复且符合特殊召唤条件时，询问玩家是否进行特殊召唤
	if Duel.Recover(p,d,REASON_EFFECT)~=0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(55725117,0)) then  --"是否特殊召唤？"
		-- 中断当前效果，使前后的回复基本分与特殊召唤效果处理视为不同时处理
		Duel.BreakEffect()
		-- 向玩家发送选择提示信息：“请选择要特殊召唤的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的「调皮宝贝」怪兽在自己场上以表侧守备表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
