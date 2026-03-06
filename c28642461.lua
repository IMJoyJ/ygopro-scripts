--K9－66a号 ヨクル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
-- ②：把手卡的这张卡和手卡1只5星怪兽给对方观看才能发动。那2只特殊召唤。这个效果特殊召唤的怪兽不能作为光属性超量怪兽的超量召唤的素材。
-- ③：自己主要阶段才能发动。从卡组把1只水族以外的「K9」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①不用解放召唤、②特殊召唤、③检索
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
-- 判断是否满足①效果的召唤条件：不需解放、等级≥5、场上存在空位、对方手卡≥2张
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足①效果的召唤条件：不需解放、等级≥5、场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断是否满足①效果的召唤条件：对方手卡≥2张
		and Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),0,LOCATION_HAND,2,nil)
end
-- 过滤函数：判断手牌中是否存在等级为5的怪兽且可特殊召唤
function s.costfilter(c,e,tp)
	return c:IsLevel(5) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的费用处理：选择1只等级为5的怪兽进行确认并洗切手牌
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- ②效果的费用检查：确认手牌中是否存在等级为5的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- ②效果的费用处理：提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- ②效果的费用处理：选择1只等级为5的怪兽进行确认
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- ②效果的费用处理：向对方确认所选怪兽
	Duel.ConfirmCards(1-tp,sc)
	-- ②效果的费用处理：洗切自己的手牌
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ②效果的目标确认：检测是否满足特殊召唤条件，包括青眼精灵龙效果限制
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- ②效果的目标确认：场上存在2个以上空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not e:GetHandler():IsPublic() end
	-- ②效果的操作信息设置：准备特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ②效果的处理：执行特殊召唤并设置不能作为光属性超量素材的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToChain,nil)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- ②效果的处理：判断场上是否还有2个以上空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if fg:GetCount()~=2 then return end
	-- ②效果的处理：执行特殊召唤操作
	if Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- ②效果的处理：遍历特殊召唤的怪兽并设置不能作为光属性超量素材的效果
		for tc in aux.Next(fg) do
			-- ②效果的处理：设置不能作为光属性超量素材的效果及提示标记
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
-- ②效果的处理：限制光属性怪兽不能作为超量素材
function s.xyzlimit(e,c)
	return c and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- ③效果的检索过滤函数：筛选水族以外的K9怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_AQUA) and c:IsAbleToHand()
end
-- ③效果的目标确认：检测卡组中是否存在满足条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ③效果的目标确认：检测卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- ③效果的操作信息设置：准备从卡组检索1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- ③效果的处理：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- ③效果的处理：选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- ③效果的处理：将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- ③效果的处理：向对方确认所选怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
