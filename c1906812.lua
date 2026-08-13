--鉄駆竜スプリンド
-- 效果：
-- 「阿不思的落胤」＋这个回合特殊召唤的效果怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动。那之后，可以把和移动过的这张卡相同纵列的其他的表侧表示卡全部破坏。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「护宝炮妖」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c1906812.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号68468459的「阿不思的落胤」和1只满足mfilter条件的怪兽作为融合素材。
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
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetOperation(c1906812.regop)
	c:RegisterEffect(e0)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「护宝炮妖」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
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
-- 定义融合素材合法性检查函数，确认选择的素材组合包含「阿不思的落胤」和1只这个回合特殊召唤的效果怪兽。
function c1906812.branded_fusion_check(tp,sg,fc)
	-- 调用gffcheck检查两组素材是否满足“其中一张为「阿不思的落胤」，另一张为本回合特殊召唤的效果怪兽”的任意排列。
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,c1906812.mfilter,nil)
end
-- 定义融合素材过滤条件：怪兽必须在这个回合被特殊召唤、是效果怪兽、且在主要怪兽区。
function c1906812.mfilter(c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsFusionType(TYPE_EFFECT) and c:IsLocation(LOCATION_MZONE)
end
-- 定义①效果的发动条件函数：仅当自己场上存在可用的其他主要怪兽区域空格时才能发动。
function c1906812.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动判定：检查自己主要怪兽区是否有空位可移动这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- 定义①效果的处理函数：将这张卡移动到选定的其他主要怪兽区域，移动成功后可选择破坏同纵列的其他表侧表示卡。
function c1906812.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理前检查：这张卡仍与效果关联、不免疫效果、控制权未变且场上仍有可用空格，否则终止处理。
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 显示“请选择要移动到的位置”的提示信息，引导玩家选择移动区域。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择一个可用的主要怪兽区域空格，返回该位置的位标记。
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	-- 向玩家展示已选择的移动区域位置。
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	local pseq=c:GetSequence()
	-- 将这张卡移动到选定的主要怪兽区域序号。
	Duel.MoveSequence(c,seq)
	if c:GetSequence()==seq then
		local g=c:GetColumnGroup():Filter(Card.IsFaceup,nil)
		-- 若存在与移动后卡片同纵列的表侧表示卡，询问玩家是否将其全部破坏。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1906812,2)) then  --"是否把同纵列表侧表示的卡全部破坏？"
			-- 中断当前效果处理，使后续的破坏效果作为独立处理，避免时点合并。
			Duel.BreakEffect()
			-- 以效果破坏同纵列的其他表侧表示卡。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 定义辅助效果操作：这张卡被送去墓地时注册一个标记，表示该回合曾被送去墓地，该标记在结束阶段重置。
function c1906812.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(1906812,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 定义②效果的发动条件：这张卡拥有本回合被送去墓地的标记。
function c1906812.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1906812)>0
end
-- 定义②效果的目标过滤：卡必须是「护宝炮妖」怪兽或「阿不思的落胤」，并且可以被加入手卡或能特殊召唤。
function c1906812.thfilter(c,e,tp)
	if not (c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取自己场上可用的主要怪兽区空格数，用于判断目标是否满足特殊召唤条件。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 定义②效果的发动目标判定：卡组中存在至少1张符合条件的卡。
function c1906812.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在符合条件的「护宝炮妖」怪兽或「阿不思的落胤」。
	if chk==0 then return Duel.IsExistingMatchingCard(c1906812.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 定义②效果的处理操作：从卡组选择1张符合条件的卡，根据玩家选择或条件决定加入手卡或特殊召唤。
function c1906812.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要操作的卡”的提示信息，引导玩家选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张符合条件的卡作为处理对象。
	local g=Duel.SelectMatchingCard(tp,c1906812.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取自己场上可用的主要怪兽区空格数，用于判断处理时能否选择特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 若该卡可以加入手卡，且（不能特殊召唤、没有空位或玩家选择加入手卡），则执行加入手卡；否则执行特殊召唤。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选择的卡加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的卡以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
