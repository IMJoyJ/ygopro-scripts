--相剣師－莫邪
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把手卡1张「相剑」卡或者1只幻龙族怪兽给对方观看才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。自己抽1张。
function c20001443.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合，把手卡1张「相剑」卡或者1只幻龙族怪兽给对方观看才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20001443,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,20001443)
	e1:SetCost(c20001443.spcost)
	e1:SetTarget(c20001443.sptg)
	e1:SetOperation(c20001443.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,20001444)
	e3:SetCondition(c20001443.drcon)
	e3:SetTarget(c20001443.drtg)
	e3:SetOperation(c20001443.drop)
	c:RegisterEffect(e3)
end
-- 定义代价过滤条件：手牌中存在「相剑」卡或幻龙族怪兽，且该卡未处于公开状态时满足条件。
function c20001443.costfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER))) and not c:IsPublic()
end
-- 代价处理：确认手牌存在符合条件的卡后，选择1张手牌的「相剑」卡或幻龙族怪兽给对方确认，然后洗切手牌，作为发动①效果的代价。
function c20001443.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，检查手牌中是否存在至少1张满足costfilter条件的卡，若没有则不可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20001443.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给发动玩家显示选择提示，要求其选择1张手牌中的卡给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让tp玩家从手牌中选择1张满足costfilter条件的卡（即「相剑」卡或幻龙族怪兽）。
	local g=Duel.SelectMatchingCard(tp,c20001443.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切tp玩家的手牌，避免对方通过确认操作获知其他手牌信息。
	Duel.ShuffleHand(tp)
end
-- ①效果发动目标的检测：确认自己的主要怪兽区有空位，且自己可以特殊召唤「相剑衍生物」。
function c20001443.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己是否可以特殊召唤「相剑衍生物」（幻龙族·调整·水·4星·攻/守0，种族/属性/等级满足）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置本次连锁将产生1只衍生物的操作信息，供相关效果（如星尘龙等）进行联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次连锁将进行特殊召唤的操作信息，标记为特殊召唤1只怪。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理①效果：若此时仍满足条件，则生成「相剑衍生物」并特殊召唤，同时为衍生物附加自肃效果——只要该衍生物存在，自己不能从额外卡组特殊召唤非同步怪兽。
function c20001443.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位，防止场上位置被占用导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果处理时再次确认自己仍可以特殊召唤指定参数的「相剑衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 在场上生成1只「相剑衍生物」（卡号20001444）的实体。
		local token=Duel.CreateToken(tp,20001444)
		-- 以表侧表示将衍生物特殊召唤到自己的主要怪兽区（分解式特殊召唤的第一步）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c20001443.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成分解式特殊召唤，正式结算衍生物的特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
-- 定义自肃效果的限制条件：仅禁止从额外卡组特殊召唤非同步怪兽。
function c20001443.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：这张卡作为同调素材被送去墓地时（且当前在墓地，原因为同调）才能发动。
function c20001443.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ②效果发动目标的设置：检测自己能否抽卡，若能则将抽卡对象玩家设为自己、抽卡数设为1，并登记抽卡操作信息。
function c20001443.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将这次效果的对象玩家设为自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将这次效果的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己将进行1次效果抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理②效果：获取目标玩家和抽卡数，实际执行抽卡。
function c20001443.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出之前设置的对象玩家和抽卡数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
