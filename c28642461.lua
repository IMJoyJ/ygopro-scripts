--K9－66a号 ヨクル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
-- ②：把手卡的这张卡和手卡1只5星怪兽给对方观看才能发动。那2只特殊召唤。这个效果特殊召唤的怪兽不能作为光属性超量怪兽的超量召唤的素材。
-- ③：自己主要阶段才能发动。从卡组把1只水族以外的「K9」怪兽加入手卡。
local s,id,o=GetID()
-- 创建并注册三个效果：①设置无解放召唤规则，②设置手牌特殊召唤并附加素材限制，③设置场上检索，并分别设定各自的1回合1次限制。
function s.initial_effect(c)
	-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤(K9-66a号 霜妖)"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：把手卡的这张卡和手卡1只5星怪兽给对方观看才能发动。那2只特殊召唤。这个效果特殊召唤的怪兽不能作为光属性超量怪兽的超量召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。从卡组把1只水族以外的「K9」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 无解放召唤的召唤规则条件函数：查询时直接允许；实际召唤需满足无解放、此卡等级≥5、己方怪兽区有空位，且对方手牌≥2张。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 召唤条件中：要求解放数量为0，此卡等级为5以上，并且自己的主要怪兽区存在可用空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 召唤条件中：对方玩家手牌中存在至少2张卡，即满足“对方手卡是2张以上”。
		and Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),0,LOCATION_HAND,2,nil)
end
-- ②效果cost用的过滤器：从手牌中选出1只5星怪兽，要求其为怪兽卡、未公开、且可以被特殊召唤。
function s.costfilter(c,e,tp)
	return c:IsLevel(5) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果cost处理：确认手牌存在满足条件的5星怪兽；选择1张展示给对方，然后洗切手牌，并将该卡与效果关联保存，供处理时使用。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- cost检查分支（chk==0）：若手牌中除自身外不存在满足costfilter的5星怪兽，则无法支付cost，效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 发出选择提示，要求玩家选择一张卡片给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择1张满足costfilter的卡片（排除发动效果的这张卡），并取得该卡片。
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 将选择的5星怪兽展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切手牌，因为刚刚向对方展示过手牌中的卡片，需要重置手牌顺序。
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ②效果的目标/发动条件检查：确认当前没有青眼精灵龙之类的“禁止同时特殊召唤2只以上怪兽”的限制；此卡自身可特殊召唤；己方怪兽区剩余空格≥2；此卡不是公开状态。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 需要己方怪兽区可用空格大于1，因为效果要同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- 登记本次连锁的特殊召唤操作信息：预定从手牌特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ②效果处理：如果存在青眼精灵龙限制、怪兽区空格不足、或任意一只怪兽不能特殊召唤则终止；否则将两张关联怪兽表侧表示特殊召唤，并为它们附加“不能作为光属性超量素材”的永续限制，同时添加客户端提示标记。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若己方怪兽区空格不足2个，则无法完成2只怪兽同时特殊召唤，效果处理直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if fg:GetCount()~=2 then return end
	-- 将两张怪兽以表侧表示特殊召唤到己方场上；若特殊召唤成功（返回值≠0），则继续处理。
	if Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 遍历特殊召唤成功的每一只怪兽，为每只怪兽执行添加限制效果的操作。
		for tc in aux.Next(fg) do
			-- 这个效果特殊召唤的怪兽不能作为光属性超量怪兽的超量召唤的素材。③：自己主要阶段才能发动。从卡组把1只水族以外的「K9」怪兽加入手卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetValue(s.xyzlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"「K9-66a号 霜妖」的效果特殊召唤"
		end
	end
end
-- 素材限制的判定函数：仅当怪兽是光属性时，才禁止它作为超量素材使用。
function s.xyzlimit(e,c)
	return c and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ③检索的过滤器：目标必须是「K9」怪兽、怪兽卡、水族以外，并且能够加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_AQUA) and c:IsAbleToHand()
end
-- ③效果的发动条件与操作信息设置：检查卡组中存在符合条件的「K9」怪兽，并登记从卡组检索加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查分支：若卡组中不存在满足检索条件的卡片，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：选择1张满足条件的「K9」怪兽从卡组加入手牌，并展示给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张符合thfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
