--カオスシルクハット
-- 效果：
-- ①：对方把怪兽的效果·通常魔法·通常陷阱卡发动时才能发动。从卡组把3张卡名不同的魔法·陷阱卡作为卡名当作「混沌礼帽」使用的通常怪兽（魔法师族·暗·8星·攻/守0），和有「光与暗的仪式」的卡名记述的自己的主要怪兽区域1只怪兽混合洗切并里侧守备表示盖放。那之后，那个对方发动的效果变成「对方场上1只里侧守备表示怪兽破坏」。
local s,id,o=GetID()
-- 初始化卡片效果：注册这张卡与记述「光与暗的仪式」的卡名关联，并注册①的诱发即时发动效果
function s.initial_effect(c)
	-- 记录本卡在规则上与卡名「光与暗的仪式」(33599853)相关联的事实
	aux.AddCodeList(c,33599853)
	-- ①：对方把怪兽的效果·通常魔法·通常陷阱卡发动时才能发动。从卡组把3张卡名不同的魔法·陷阱卡作为卡名当作「混沌礼帽」使用的通常怪兽（魔法师族·暗·8星·攻/守0），和有「光与暗的仪式」的卡名记述的自己的主要怪兽区域1只怪兽混合洗切并里侧守备表示盖放。那之后，那个对方发动的效果变成「对方场上1只里侧守备表示怪兽破坏」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- ①效果的发动条件：对方把怪兽的效果、或者通常魔法·通常陷阱卡发动时
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandlerPlayer()~=1-tp then return false end
	local rc=re:GetHandler()
	return ((rc:GetType()==TYPE_TRAP or rc:GetType()==TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) or re:IsActiveType(TYPE_MONSTER)
end
-- 过滤自己主要怪兽区域且有「光与暗的仪式」的卡名记述的可以转为里侧守备表示的怪兽
function s.filter(c)
	-- 检查该怪兽是否记述了「光与暗的仪式」、处于前5格主要怪兽区，且可转为里侧表示
	return aux.IsCodeListed(c,33599853) and c:GetSequence()<5 and c:IsCanTurnSet()
end
-- 过滤卡组中可特殊召唤为怪兽的魔法·陷阱卡
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		-- 判定该魔法/陷阱卡是否可以作为魔法师族·暗属性·8星·攻守0的通常怪兽在自己的怪兽区域以里侧守备表示进行特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xcf,TYPES_NORMAL_TRAP_MONSTER,0,0,8,RACE_SPELLCASTER,ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEDOWN_DEFENSE)
end
-- ①效果的发动准备与合法性检查：确认自己场上存在符合条件的怪兽、没有受到青眼精灵龙特招数量限制、自己主要怪兽区域有3个以上的空位，且卡组中存在3种以上卡名互不相同的魔法·陷阱卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中满足召唤条件的所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 效果发动时，检查自己场上是否存在符合条件的、记述了「光与暗的仪式」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查当前召唤玩家的主要怪兽区域空位是否多于2个（即至少需要3个空格）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and g:GetClassCount(Card.GetCode)>=3
	end
	-- 设置效果处理信息：从卡组将3张卡片以特殊召唤的方式出场
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
end
-- ①效果的效果处理：在不受精灵龙效果影响且格子充足的状况下，选择自己场上1只记述了「光与暗的仪式」的怪兽转为里侧守备表示，从卡组特殊召唤3张卡名不同的魔法·陷阱卡作为属性·种族·星级·攻守修改后的里侧守备通常怪兽，并将它们与场上的那只怪兽混合洗切里侧盖放，最后将对方的连锁效果变更为“破坏对方场上的1只里侧守备表示怪兽”
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查当前玩家的主要怪兽区域空位是否少于3个
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 获取卡组中可以被特殊召唤的魔法·陷阱卡集合
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 确认这些魔法·陷阱卡中是否包含至少3种卡名不同的卡
	if not g:CheckSubGroup(aux.dncheck,3,3) then return end
	-- 提示玩家选择自己场上作为效果对象的那只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家从自己场上选择1只记述了「光与暗的仪式」的怪兽
	local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g2:GetFirst()
	if not tc or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择卡组里要特殊召唤的3张魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选择3张卡名不同的魔法·陷阱卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if not sg or sg:GetCount()~=3 then return end
	-- 在场上显式标出作为对象的怪兽的动画效果
	Duel.HintSelection(g2)
	if tc:IsFaceup() then
		-- 如果那只对象怪兽是表侧表示，则将其变为里侧守备表示并重置其与当前连锁的关联性
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		-- 获取对方发动的需要变更处理的连锁效果
		local ce=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
		tc:ReleaseEffectRelation(ce)
	end
	-- 循环处理被选中的3张从卡组特殊召唤的魔法·陷阱卡
	for sc in aux.Next(sg) do
		-- 将这些卡片作为怪兽以里侧守备表示逐一特殊召唤到场上
		Duel.SpecialSummonStep(sc,0,tp,tp,true,true,POS_FACEDOWN_DEFENSE)
		-- 为这只特殊召唤的卡片注册怪兽属性：使其成为暗属性、魔法师族、8星、攻守0、卡名当作「混沌礼帽」使用的通常怪兽
		local e1=Effect.CreateEffect(sc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_NORMAL+TYPE_MONSTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		sc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(8)
		sc:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetValue(RACE_SPELLCASTER)
		sc:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e4:SetValue(ATTRIBUTE_DARK)
		sc:RegisterEffect(e4,true)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_SET_BASE_ATTACK)
		e5:SetValue(0)
		sc:RegisterEffect(e5,true)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_SET_BASE_DEFENSE)
		e6:SetValue(0)
		sc:RegisterEffect(e6,true)
		local e7=e1:Clone()
		e7:SetCode(EFFECT_CHANGE_CODE)
		e7:SetValue(id)
		sc:RegisterEffect(e7,true)
	end
	-- 完成批量特殊召唤的过程并进行时点确认
	Duel.SpecialSummonComplete()
	-- 将这3张特殊召唤的魔法·陷阱卡展示给对方确认
	Duel.ConfirmCards(1-tp,sg)
	sg:AddCard(tc)
	-- 将上述3张卡与转为里侧守备表示的那1只怪兽放入同一个卡组组里混合洗切并里侧盖放
	Duel.ShuffleSetCard(sg)
	local tg=Group.CreateGroup()
	-- 清空该连锁中原本指向的目标卡片对象
	Duel.ChangeTargetCard(ev,tg)
	-- 将该连锁效果的处理逻辑变更为本卡设定的替换效果
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 对方发动的连锁效果被修改后的替换效果处理逻辑：对方选择自己场上1只里侧守备表示的怪兽破坏
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 对方玩家从我方场上选择1只里侧守备表示的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 在场上显式标出要破坏的怪兽
		Duel.HintSelection(g)
		-- 将选中的里侧守备表示怪兽由于效果破坏送入墓地
		Duel.Destroy(g,REASON_EFFECT)
	end
end
