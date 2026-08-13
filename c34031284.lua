--おジャマ・エンペラー
-- 效果：
-- 包含「扰乱」怪兽的兽族怪兽3只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：场地区域有「扰乱之乡」存在的场合，这张卡攻击力上升3000，不会被效果破坏。
-- ②：向这张卡的攻击发生的对自己的战斗伤害由对方代受。
-- ③：以连接怪兽以外的自己墓地1只「扰乱」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
function c34031284.initial_effect(c)
	-- 将「扰乱之乡」（卡号90011152）登记进这张卡的卡名列表，使系统识别这张卡的文本中记载了「扰乱之乡」，用于辅助其召唤条件与①效果的关联判定。
	aux.AddCodeList(c,90011152)
	-- 为这张卡设置连接召唤手续：必须且只能用3只兽族怪兽作为连接素材，并且素材组中至少包含1只「扰乱」怪兽，对应其召唤条件“包含「扰乱」怪兽的兽族怪兽3只”。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST),3,3,c34031284.lcheck)
	c:EnableReviveLimit()
	-- ①：场地区域有「扰乱之乡」存在的场合，这张卡攻击力上升3000，不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c34031284.condition)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：向这张卡的攻击发生的对自己的战斗伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetCondition(c34031284.refcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：以连接怪兽以外的自己墓地1只「扰乱」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34031284,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,34031284)
	e4:SetTarget(c34031284.target)
	e4:SetOperation(c34031284.operation)
	c:RegisterEffect(e4)
end
-- 连接素材的追加检查函数：确认所选素材组中至少存在1只「扰乱」怪兽，以满足“包含「扰乱」怪兽”这一召唤素材要求。
function c34031284.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xf)
end
-- ①效果的条件函数：检查场地区域是否有「扰乱之乡」（卡号90011152），有则该卡的①效果适用。
function c34031284.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前生效的场地卡是否为「扰乱之乡」，且不限制控制者，只检查场地区域；若是则返回true。
	return Duel.IsEnvironment(90011152,PLAYER_ALL,LOCATION_FZONE)
end
-- ②效果的条件函数：判定这张卡是否正被选为攻击对象，若是则战斗伤害反射效果适用。
function c34031284.refcon(e)
	-- 返回当前攻击目标是否就是这张卡本身，用于确认“向这张卡的攻击”这一情况。
	return Duel.GetAttackTarget()==e:GetHandler()
end
-- ③效果的对象筛选条件：选择自己墓地1只「扰乱」系列怪兽，要求是怪兽且不是连接怪兽，并且可以被特殊召唤。
function c34031284.filter(c,e,tp)
	return c:IsSetCard(0xf) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动目标处理：在发动时先检查是否存在合法对象（墓地符合条件的「扰乱」怪兽），并验证自己场上是否有特殊召唤的空格；满足条件后允许发动。
function c34031284.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c34031284.filter(chkc,e,tp) end
	-- 发动条件检查：自己场上主要怪兽区是否存在可用的空格，以确认可以特殊召唤目标怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地是否存在至少1只符合筛选条件的「扰乱」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c34031284.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示信息，引导玩家选择墓地要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从自己墓地选择1只符合条件的「扰乱」怪兽，并将其设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c34031284.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息为特殊召唤分类，对象是已选中的那只怪兽，数量为1，供其他卡的效果正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：将选中的对象怪兽特殊召唤到自己场上，然后给己方附加“这个回合不能从额外卡组特殊召唤融合怪兽以外的怪兽”的自肃效果。
function c34031284.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁发动时选择的那只墓地「扰乱」怪兽作为要特殊召唤的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34031284.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述特殊召唤自肃效果注册到场上，生效对象为己方玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤器：对于从额外卡组特殊召唤的怪兽，如果不是融合怪兽则返回true，表示禁止其特殊召唤。
function c34031284.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
