--無限竜シュヴァルツシルト
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族超量怪兽不能从额外卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2000以上的怪兽存在的场合才能发动。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。这个效果从卡组特殊召唤的怪兽的效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果：注册从手卡特殊召唤自身并从卡组特召怪兽的起动效果，以及用于誓约自肃的特殊召唤活动计数器
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次，①：自己场上没有怪兽存在的场合或者对方场上有攻击力2000以上的怪兽存在的场合才能发动。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤自身并特殊召唤卡组"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 注册全局特殊召唤活动计数器，追踪本回合是否曾从额外卡组特殊召唤过非龙族超量怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：若怪兽并非从额外卡组召唤，或为表侧表示的龙族超量怪兽则返回true（不计入违规操作）
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsFaceup())
end
-- 过滤场上表侧表示且攻击力在2000以上的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000)
end
-- 检查发动条件：己方怪兽区没有怪兽，或对方怪兽区存在攻击力2000以上的表侧怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方怪兽区是否存在0只怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 或判断对方怪兽区是否存在至少1只攻击力2000以上的表侧怪兽
		or Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp)
end
-- 检查并施加誓约代价：确认本回合此前未从额外卡组特召过非龙族超量怪兽，并注册本回合剩余时间内禁止从额外卡组特召龙族超量以外怪兽的誓约限制
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前确认己方本回合尚未进行过违背誓约（从额外卡组特召非龙族超量怪兽）的操作
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是龙族超量怪兽不能从额外卡组特殊召唤。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 为己方玩家注册持续至回合结束的额外卡组特殊召唤自肃效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：阻止从额外卡组特殊召唤非龙族超量怪兽
function s.splimit(e,c)
	return not (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤卡组中除「无限龙 施瓦西龙」外、可表侧守备表示特殊召唤的光或暗属性·龙族·8星怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLevel(8)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动前确认：未受「青眼精灵龙」限制同时特召2只以上的效果影响、己方怪兽区至少有2个空位、手卡的此卡与卡组目标怪兽均可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方怪兽区可用空位是否大于1（即至少2格）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查己方卡组是否存在至少1只符合条件的8星光·暗属性龙族怪兽可供特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记将此卡自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：分步特殊召唤手卡的此卡后，从卡组选1只符合条件的怪兽表侧守备表示特殊召唤并将其场上效果无效化，最后统一完成特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 向己方发送从卡组选择要特殊召唤的怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从卡组选择1只符合条件的光·暗属性龙族·8星怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 分步将选中的卡组怪兽以表侧守备表示特殊召唤到己方场上
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这个效果从卡组特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
			-- 这个效果从卡组特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e2)
		end
	end
	-- 完成分步特殊召唤流程，统一结算两只怪兽的特殊召唤成功时点
	Duel.SpecialSummonComplete()
end
