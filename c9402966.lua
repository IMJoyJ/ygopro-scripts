--超重武者タマ－C
-- 效果：
-- 「超重武者 魂-C」的效果1回合只能使用1次。
-- ①：自己场上没有「超重武者」怪兽以外的怪兽存在，自己墓地没有魔法·陷阱卡存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡从场上送去墓地。那之后，把持有和送去墓地的那2只怪兽的原本等级合计相同等级的1只「超重武者」同调怪兽从额外卡组当作同调召唤作特殊召唤。
function c9402966.initial_effect(c)
	-- 「超重武者 魂-C」的效果1回合只能使用1次。①：自己场上没有「超重武者」怪兽以外的怪兽存在，自己墓地没有魔法·陷阱卡存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡从场上送去墓地。那之后，把持有和送去墓地的那2只怪兽的原本等级合计相同等级的1只「超重武者」同调怪兽从额外卡组当作同调召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9402966)
	e1:SetCondition(c9402966.sccon)
	e1:SetTarget(c9402966.sctg)
	e1:SetOperation(c9402966.scop)
	c:RegisterEffect(e1)
end
-- 过滤条件：里侧表示怪兽或者非「超重武者」怪兽
function c9402966.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x9a)
end
-- 效果发动条件：自己场上没有「超重武者」以外的怪兽，且自己墓地没有魔法·陷阱卡
function c9402966.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在里侧表示怪兽或非「超重武者」怪兽（即：自己场上没有「超重武者」怪兽以外的怪兽存在）
	return not Duel.IsExistingMatchingCard(c9402966.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在魔法·陷阱卡（即：自己墓地没有魔法·陷阱卡存在）
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 过滤条件：对方场上表侧表示、有等级，且额外卡组存在可特殊召唤的对应等级「超重武者」同调怪兽
function c9402966.filter(c,e,tp,lv,mc)
	return c:IsFaceup() and c:GetLevel()>0
		-- 检查额外卡组是否存在等级等于两只怪兽原本等级合计的、可特殊召唤的「超重武者」同调怪兽
		and Duel.IsExistingMatchingCard(c9402966.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+c:GetOriginalLevel(),Group.FromCards(c,mc))
end
-- 过滤条件：额外卡组中等级等于指定数值、可当作同调召唤特殊召唤的「超重武者」同调怪兽
function c9402966.scfilter(c,e,tp,lv,mg)
	return c:IsSetCard(0x9a) and c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO)
		-- 检查该卡是否能以同调召唤方式特殊召唤，且额外怪兽区域或可用主怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 效果发动准备：选择对方场上1只表侧表示怪兽作为对象，并声明送去墓地和特殊召唤的操作信息
function c9402966.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local lv=c:GetOriginalLevel()
	-- 检查是否存在可作为对象的对方场上表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c9402966.filter,tp,0,LOCATION_MZONE,1,nil,e,tp,lv,c)
		-- 检查是否存在必须作为同调素材的限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9402966.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp,lv,c)
	g:AddCard(c)
	-- 设置操作信息：将这2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将自身和对象怪兽送去墓地，之后从额外卡组将对应等级的「超重武者」同调怪兽当作同调召唤特殊召唤
function c9402966.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	-- 再次检查必须作为同调素材的限制，若不满足则不处理效果
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	-- 将自身和对象怪兽送去墓地，并确认2张卡都成功送去墓地且自身在墓地中存在等级
	if Duel.SendtoGrave(g,REASON_EFFECT)==2 and c:GetLevel()>0 and c:IsLocation(LOCATION_GRAVE)
		and tc:GetLevel()>0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足等级合计条件的「超重武者」同调怪兽
		local sg=Duel.SelectMatchingCard(tp,c9402966.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
		local tc=sg:GetFirst()
		if tc then
			-- 中断当前效果处理，使后续的特殊召唤处理不与送去墓地同时进行
			Duel.BreakEffect()
			tc:SetMaterial(nil)
			-- 将选择的同调怪兽当作同调召唤在自己场上表侧表示特殊召唤
			if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
