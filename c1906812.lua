--鉄駆竜スプリンド
-- 效果：
-- 「阿不思的落胤」＋这个回合特殊召唤的效果怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动。那之后，可以把和移动过的这张卡相同纵列的其他的表侧表示卡全部破坏。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「护宝炮妖」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c1906812.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号68468459的怪兽和1个满足mfilter条件的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,68468459,c1906812.mfilter,1,true,true)
	-- ①：自己主要阶段才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动。那之后，可以把和移动过的这张卡相同纵列的其他的表侧表示卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1906812,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,1906812)
	e1:SetTarget(c1906812.seqtg)
	e1:SetOperation(c1906812.seqop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「护宝炮妖」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetOperation(c1906812.regop)
	c:RegisterEffect(e0)
	-- 为卡片添加一个永续效果，当此卡被送去墓地时，记录一个标记
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1906812,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,1906813)
	e2:SetCondition(c1906812.thcon)
	e2:SetTarget(c1906812.thtg)
	e2:SetOperation(c1906812.thop)
	c:RegisterEffect(e2)
end
-- 融合召唤手续检查函数，用于验证融合素材是否满足条件
function c1906812.branded_fusion_check(tp,sg,fc)
	-- 检查融合素材是否包含一张卡号为68468459的融合怪兽和一张满足mfilter条件的怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,c1906812.mfilter,nil)
end
-- 过滤函数，用于筛选在自己场上、这个回合被特殊召唤的、类型为效果怪兽的怪兽
function c1906812.mfilter(c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsFusionType(TYPE_EFFECT) and c:IsLocation(LOCATION_MZONE)
end
-- 效果处理函数，用于判断是否可以发动效果
function c1906812.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- 效果处理函数，用于执行效果
function c1906812.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否还在场上、是否免疫效果、是否为玩家控制、是否有足够的怪兽区域
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择一个可用的怪兽区域
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	-- 提示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	local pseq=c:GetSequence()
	-- 将此卡移动到指定区域
	Duel.MoveSequence(c,seq)
	if c:GetSequence()==seq then
		local g=c:GetColumnGroup():Filter(Card.IsFaceup,nil)
		-- 判断是否选择破坏同纵列的卡
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1906812,2)) then  --"是否把同纵列表侧表示的卡全部破坏？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏满足条件的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 效果处理函数，用于记录标记
function c1906812.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(1906812,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否可以发动效果
function c1906812.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1906812)>0
end
-- 过滤函数，用于筛选可以加入手牌或特殊召唤的卡
function c1906812.thfilter(c,e,tp)
	if not (c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果处理函数，用于判断是否可以发动效果
function c1906812.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1906812.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果处理函数，用于执行效果
function c1906812.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c1906812.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择将卡加入手牌
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方看到该卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将卡特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
