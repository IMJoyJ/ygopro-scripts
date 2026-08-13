--幻奏の音女カノン
-- 效果：
-- 「幻奏的音女 卡农」的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「幻奏」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，以自己场上1只「幻奏」怪兽为对象才能发动。那只怪兽的表示形式变更。
function c16021142.initial_effect(c)
	-- 「幻奏的音女 卡农」的①的方法的特殊召唤1回合只能有1次；①：自己场上有「幻奏」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,16021142+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c16021142.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只「幻奏」怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16021142,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c16021142.postg)
	e2:SetOperation(c16021142.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且属于「幻奏」系列（0x9b）。
function c16021142.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- ①效果的特殊召唤条件：c为nil时视为满足（供规则判定）；否则要求我方主要怪兽区有空位，且我方场上有表侧表示的「幻奏」怪兽。
function c16021142.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断我方场上是否有可用的主要怪兽区空格（保证能从手卡特殊召唤）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方场上是否存在至少1只表侧表示的「幻奏」怪兽。
		and Duel.IsExistingMatchingCard(c16021142.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②的取对象筛选：对象需为表侧表示且属于「幻奏」系列，并且可以变更表示形式。
function c16021142.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b) and c:IsCanChangePosition()
end
-- ②的发动条件和对象处理：若指定对象则校验对象满足条件；发动时检查存在合法对象；提示玩家选择1只「幻奏」怪兽，将其设为对象，并设置变更表示形式的操作信息。
function c16021142.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c16021142.filter(chkc) end
	-- 发动时（chk==0）检查我方场上是否存在1只符合条件的「幻奏」怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c16021142.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要改变表示形式的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从我方场上选择1只符合条件的「幻奏」怪兽作为效果对象（并登记为当前连锁的对象）。
	local g=Duel.SelectTarget(tp,c16021142.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：该效果将执行改变表示形式的处理，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②的效果处理：取得对象怪兽，若对象仍与此效果关联（未离场/未失效），则将其表示形式变更（表侧攻击与表侧守备互换）。
function c16021142.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式进行变更（表侧攻击变为表侧守备，表侧守备变为表侧攻击）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
