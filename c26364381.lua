--デミウルゴスEMA
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·场上（表侧表示）把4只攻击力2400以上而守备力1000的怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：以自己以及对方场上的魔法·陷阱卡各1张为对象才能发动。那些卡破坏。那之后，在双方场上把「人工生命体衍生物」（天使族·光·2星·攻/守800）各1只守备表示特殊召唤，这张卡的攻击力上升1600。
local s,id,o=GetID()
-- 注册“造物主 埃玛”的卡片效果：①从手卡·卡组·场上送去4只指定面板怪兽做代价从手卡特召自身的起动效果，②双重破坏场上魔陷后在双方场上特召「人工生命体衍生物」且自身攻击力上升的起动效果
function s.initial_effect(c)
	-- ①：从自己的手卡·卡组·场上（表侧表示）把4只攻击力2400以上而守备力1000的怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己以及对方场上的魔法·陷阱卡各1张为对象才能发动。那些卡破坏。那之后，在双方场上把「人工生命体衍生物」（天使族·光·2星·攻/守800）各1只守备表示特殊召唤，这张卡的攻击力上升1600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·卡组中、或自己场上表侧表示存在的，能作为代价送去墓地的，且攻击力2400以上、守备力1000的怪兽卡
function s.sprfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGraveAsCost()
		and c:IsAttackAbove(2400) and c:IsDefense(1000)
end
-- 判断选择的卡片离开场上/手卡/卡组后是否仍能满足己方的怪兽区空间要求
function s.gcheck(g,tp)
	-- 判断在玩家场上这组选中的卡片离开后可用的怪兽区数量是否大于0
	return Duel.GetMZoneCount(tp,g)>0
end
-- 效果①的Cost处理：验证是否可发动，并从手卡·卡组·场上选择4只符合条件的怪兽送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·卡组·场上（除此卡外）符合送去墓地条件的全部目标怪兽
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(s.gcheck,4,4,tp) end
	-- 给玩家发送提示：请选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,4,4,tp)
	-- 将选择的4只怪兽送去墓地作为发动的代价
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 效果①的发动准备：判断此卡自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：从手卡特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的操作处理：如果此卡与连锁相关，则将其在自己场上特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 将此卡从手卡表侧表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：魔法·陷阱卡，且它们被破坏后双方玩家均有可用的怪兽区（用于Token特召），且可以被效果选为对象
function s.desfilter(c,e)
	-- 判断目标是否为魔法·陷阱卡，且该卡片离开后其控制者场上至少有1个空闲怪兽区
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(c:GetControler(),c)>0
		and c:IsCanBeEffectTarget(e)
end
-- 判断玩家选择的卡组是否在自己与对方场上各有1张魔法·陷阱卡
function s.gcheck2(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)==g:FilterCount(Card.IsControler,nil,1-tp)
end
-- 效果②的发动准备：以双方场上各1张魔法·陷阱卡为对象发动，同时验证双方场上是否能进行Token特殊召唤，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方场上所有符合条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck2,2,2,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断在自己场上是否能特殊召唤符合特定属性和数值的「人工生命体衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE)
		-- 判断在对方场上是否能特殊召唤符合特定属性和数值的「人工生命体衍生物」并且结束验证
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) end
	local sg=g:SelectSubGroup(tp,s.gcheck2,false,2,2,tp)
	-- 将玩家选择的2张魔法·陷阱卡保存为当前连锁的对象卡
	Duel.SetTargetCard(sg)
	-- 设置操作信息：破坏被选中的这2张卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- 效果②的操作处理：破坏选中的2张魔法·陷阱卡，之后在双方场上以守备表示特殊召唤「人工生命体衍生物」，最后此卡攻击力上升1600
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁中被选为对象的魔法·陷阱卡并过滤出当前仍存在于场上的卡
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	-- 若存在受此效果影响的目标卡且将其破坏成功
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 检查己方怪兽区域是否还有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			-- 检查对方怪兽区域是否还有空位
			or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0
			-- 检查自己是否可以特殊召唤「人工生命体衍生物」
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE)
			-- 检查对方是否可以特殊召唤「人工生命体衍生物」并结束判断
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,800,800,2,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		-- 创建代表自己场上的「人工生命体衍生物」的卡片数据
		local token1=Duel.CreateToken(tp,id+o)
		-- 创建代表对方场上的「人工生命体衍生物」的卡片数据
		local token2=Duel.CreateToken(tp,id+o)
		-- 中断效果处理，使之后的特殊召唤与之前的破坏不视为同时处理
		Duel.BreakEffect()
		-- 在自己场上以守备表示特殊召唤己方的衍生物（不完成全部过程）
		Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 在对方场上以守备表示特殊召唤对方的衍生物（不完成全部过程）
		Duel.SpecialSummonStep(token2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		-- 完成双方场上所有使用Step特殊召唤怪兽的最终处理
		Duel.SpecialSummonComplete()
		if c:IsFaceup() and c:IsRelateToChain() then
			-- 这张卡的攻击力上升1600。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
