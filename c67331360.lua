--人形の家
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只攻击力或守备力是0的通常怪兽为对象才能发动。那1只同名怪兽从卡组作为暗属性·6星怪兽特殊召唤。自己场上有「珂珑公主」存在的场合，这个效果的对象可以变成2只。
-- ②：对方怪兽的攻击宣言时才能发动。选自己场上1只「德梅特爷爷」作为自己场上的「珂珑公主」的超量素材。那之后，战斗阶段结束。
function c67331360.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：以自己墓地1只攻击力或守备力是0的通常怪兽为对象才能发动。那1只同名怪兽从卡组作为暗属性·6星怪兽特殊召唤。自己场上有「珂珑公主」存在的场合，这个效果的对象可以变成2只。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67331360,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,67331360)
	e1:SetTarget(c67331360.sptg)
	e1:SetOperation(c67331360.spop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时才能发动。选自己场上1只「德梅特爷爷」作为自己场上的「珂珑公主」的超量素材。那之后，战斗阶段结束。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67331360,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c67331360.matcon)
	e2:SetTarget(c67331360.mattg)
	e2:SetOperation(c67331360.matop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中攻击力或守备力为0的通常怪兽，且卡组中存在其同名怪兽
function c67331360.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeEffectTarget(e)
		-- 检查卡组中是否存在该怪兽的同名卡且可以特殊召唤
		and Duel.IsExistingMatchingCard(c67331360.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode(),nil)
end
-- 过滤卡组中卡名为指定卡名且可以特殊召唤的怪兽
function c67331360.spfilter(c,e,tp,code,code2)
	return c:IsCode(code,code2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤自己场上表侧表示的「珂珑公主」
function c67331360.cfilter(c)
	return c:IsFaceup() and c:IsCode(75574498)
end
-- 检查选择的墓地怪兽组是否能在卡组中找到对应的同名怪兽进行特殊召唤
function c67331360.gcheck(sg,e,tp)
	if #sg==1 then return true end
	local code1=sg:GetFirst():GetCode()
	local code2=sg:GetNext():GetCode()
	-- 获取卡组中满足特殊召唤条件的同名怪兽组
	local tg=Duel.GetMatchingGroup(c67331360.spfilter,tp,LOCATION_DECK,0,nil,e,tp,code1,code2)
	-- 检查卡组中是否能同时选出两张卡，分别对应两个不同的卡名
	return tg:CheckSubGroup(aux.gfcheck,2,2,Card.IsCode,code1,code2)
end
-- 效果①的发动准备与目标选择
function c67331360.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67331360.filter(chkc,e,tp) end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查自己场上是否有空位，且墓地是否存在符合条件的对象
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c67331360.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ct=math.min(2,ft)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 若自己场上没有「珂珑公主」，则将可选择的对象数量限制为1只
		or not Duel.IsExistingMatchingCard(c67331360.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then ct=1 end
	-- 获取墓地中所有符合条件的可选择对象
	local g=Duel.GetMatchingGroup(c67331360.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c67331360.gcheck,false,1,ct,e,tp)
	-- 将选择的卡片设为当前效果的对象
	Duel.SetTargetCard(tg)
	-- 设置特殊召唤的操作信息，包含特殊召唤的数量和来源（卡组）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#tg,tp,LOCATION_DECK)
end
-- 效果①的处理（特殊召唤同名怪兽并改变属性和等级）
function c67331360.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取仍与当前效果关联的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local code1,code2
	local tc=tg:GetFirst()
	while tc do
		-- 检查卡组中是否仍存在该对象怪兽的同名卡
		if Duel.IsExistingMatchingCard(c67331360.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,tc:GetCode(),nil) then
			if code1==nil then code1=tc:GetCode() else code2=tc:GetCode() end
		end
		tc=tg:GetNext()
	end
	if code1==nil then return end
	local sg
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or ft==1 or code2==nil then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1张与对象同名的怪兽
		sg=Duel.SelectMatchingCard(tp,c67331360.spfilter,tp,LOCATION_DECK,0,1,1,sg,e,tp,code1,code2)
	else
		-- 获取卡组中所有符合特殊召唤条件的同名怪兽
		local g=Duel.GetMatchingGroup(c67331360.spfilter,tp,LOCATION_DECK,0,nil,e,tp,code1,code2)
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择2张不同卡名的同名怪兽（分别对应两个墓地对象）
		sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsCode,code1,code2)
	end
	if not sg then return end
	local sc=sg:GetFirst()
	while sc do
		-- 将怪兽以表侧表示特殊召唤到场上（分步处理）
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		-- 作为暗属性·6星怪兽特殊召唤
		local e1=Effect.CreateEffect(sc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(6)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		-- 作为暗属性·6星怪兽特殊召唤
		local e2=Effect.CreateEffect(sc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(ATTRIBUTE_DARK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
		sc=sg:GetNext()
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件判定（对方怪兽的攻击宣言时）
function c67331360.matcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方（即对方回合的攻击宣言）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤自己场上表侧表示且可以作为超量素材的「德梅特爷爷」
function c67331360.matfilter(c)
	return c:IsCode(44190146) and c:IsFaceup() and c:IsCanOverlay()
end
-- 效果②的发动准备与可行性检查
function c67331360.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以作为超量素材的「德梅特爷爷」
	if chk==0 then return Duel.IsExistingMatchingCard(c67331360.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在「珂珑公主」
		and Duel.IsExistingMatchingCard(c67331360.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的处理（将「德梅特爷爷」作为「珂珑公主」的超量素材，并结束战斗阶段）
function c67331360.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要作为超量素材的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己场上1只「德梅特爷爷」
	local g1=Duel.SelectMatchingCard(tp,c67331360.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g1:GetCount()>0 then
		-- 提示玩家选择表侧表示的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择自己场上1只「珂珑公主」
		local g2=Duel.SelectMatchingCard(tp,c67331360.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g2:GetFirst()
		-- 将选择的「德梅特爷爷」重叠作为「珂珑公主」的超量素材
		if tc and not tc:IsImmuneToEffect(e) and Duel.Overlay(tc,g1)~=0 then
			-- 划分效果处理时点，使后续的战斗阶段结束处理不与重叠素材同时发生
			Duel.BreakEffect()
			-- 跳过对方的战斗阶段，使战斗阶段结束
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		end
	end
end
