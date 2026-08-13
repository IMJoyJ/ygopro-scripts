--ヌメロン・クリエイション
-- 效果：
-- 这个卡名在规则上也当作「银河眼」卡使用。这个卡名的效果1回合只能适用1次。
-- ①：原本攻击力是3000以上的龙族·光属性怪兽在场上有3只以上存在的场合才能发动。从额外卡组把1只龙族「No.」超量怪兽特殊召唤。那之后，把场上的这张卡在那只怪兽下面重叠作为超量素材。
function c46382143.initial_effect(c)
	-- 这个卡名在规则上也当作「银河眼」卡使用。这个卡名的效果1回合只能适用1次。①：原本攻击力是3000以上的龙族·光属性怪兽在场上有3只以上存在的场合才能发动。从额外卡组把1只龙族「No.」超量怪兽特殊召唤。那之后，把场上的这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c46382143.condition)
	e1:SetTarget(c46382143.target)
	e1:SetOperation(c46382143.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选满足光属性、龙族、原本攻击力3000以上且表侧表示的怪兽。
function c46382143.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:GetBaseAttack()>=3000 and c:IsFaceup()
end
-- 定义发动条件：检查双方场上是否存在至少3只满足cfilter条件的怪兽。
function c46382143.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计以tp方视角看双方主要怪兽区中满足cfilter的怪兽数量，数量大于等于3时条件成立。
	return Duel.GetMatchingGroupCount(c46382143.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>=3
end
-- 定义特殊召唤筛选函数：从额外卡组筛选龙族、No.、超量、可被特殊召唤且额外区域有空位的怪兽。
function c46382143.spfilter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外卡组的超量怪兽需要额外怪兽区或可用主怪兽区才能出场，这里确认存在足够的特殊召唤区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义效果发动时的目标选择条件：确认本回合尚未适用过此卡名效果，且额外卡组存在可特殊召唤的符合条件的怪兽。
function c46382143.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查（chk==0）：本回合不能已经适用过此卡名的效果（1回合1次限制）。
	if chk==0 then return Duel.GetFlagEffect(tp,46382143)==0
		-- 额外卡组中必须存在至少1只由spfilter筛选出的符合条件的龙族「No.」超量怪兽。
		and Duel.IsExistingMatchingCard(c46382143.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行特殊召唤，对象来源为额外卡组，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：若本回合已适用过此效果则直接结束；否则注册1回合1次标志，选择符合条件的额外怪兽特殊召唤，成功后把此卡叠放为超量素材。
function c46382143.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认本回合尚未适用过此效果，防止重复处理。
	if Duel.GetFlagEffect(tp,46382143)~=0 then return end
	-- 给玩家注册“源数创造”本回合已适用过的标志，于结束阶段重置。
	Duel.RegisterFlagEffect(tp,46382143,RESET_PHASE+PHASE_END,0,1)
	local c=e:GetHandler()
	-- 显示选择提示消息，要求玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只符合spfilter条件的怪兽，并取第一张作为特殊召唤对象。
	local tc=Duel.SelectMatchingCard(tp,c46382143.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 判断特殊召唤是否成功且被召唤的怪兽仍位于主要怪兽区，同时此卡仍在场上、与效果相关且可以作为超量素材。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLocation(LOCATION_MZONE)
		and c:IsLocation(LOCATION_ONFIELD) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		-- 中断当前效果处理，使后续的叠放处理视为另一次效果处理，避免错过时点。
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将此卡叠放在特殊召唤成功的「No.」超量怪兽下面作为其超量素材。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
