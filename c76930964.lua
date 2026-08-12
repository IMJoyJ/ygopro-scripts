--黄昏の忍者将軍－ゲツガ
-- 效果：
-- 这张卡可以把1只「忍者」怪兽解放作上级召唤。「黄昏之忍者将军-月牙」的效果1回合只能使用1次。
-- ①：这张卡在场上攻击表示存在的场合，以「黄昏之忍者将军-月牙」以外的自己墓地2只「忍者」怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽特殊召唤。
function c76930964.initial_effect(c)
	-- 这张卡可以把1只「忍者」怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76930964,0))  --"把1只「忍者」怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c76930964.otcon)
	e1:SetOperation(c76930964.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡在场上攻击表示存在的场合，以「黄昏之忍者将军-月牙」以外的自己墓地2只「忍者」怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,76930964)
	e3:SetCondition(c76930964.spcon)
	e3:SetTarget(c76930964.sptg)
	e3:SetOperation(c76930964.spop)
	c:RegisterEffect(e3)
end
-- 过滤用于上级召唤解放的「忍者」怪兽
function c76930964.otfilter(c,tp)
	return c:IsSetCard(0x2b) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤规则效果的判定条件
function c76930964.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有可作为解放素材的「忍者」怪兽
	local mg=Duel.GetMatchingGroup(c76930964.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定自身等级是否在7星以上、所需最少祭品数是否不大于1，且场上是否存在1个可用的解放素材
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤规则效果的解放处理
function c76930964.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有可作为解放素材的「忍者」怪兽
	local mg=Duel.GetMatchingGroup(c76930964.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只「忍者」怪兽作为解放素材
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选择的怪兽用于上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判定这张卡是否在场上表侧攻击表示存在
function c76930964.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤自己墓地「黄昏之忍者将军-月牙」以外且可以特殊召唤的「忍者」怪兽
function c76930964.filter(c,e,tp)
	return c:IsSetCard(0x2b) and not c:IsCode(76930964) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（判定是否满足发动条件、选择对象并声明特殊召唤操作信息）
function c76930964.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c76930964.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定自己场上的怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判定自己墓地是否存在至少2只满足条件的「忍者」怪兽
		and Duel.IsExistingTarget(c76930964.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只满足条件的「忍者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c76930964.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置特殊召唤2只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果①的效果处理（自身变守备表示，并将作为对象的怪兽特殊召唤）
function c76930964.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsDefensePos() then return end
	-- 将这张卡变成表侧守备表示
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	-- 获取自己场上可用的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取仍与当前效果关联的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 将作为对象的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
