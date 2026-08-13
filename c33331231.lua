--閃術兵器－H.A.M.P.
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「闪刀姬」怪兽存在的场合，这张卡可以把自己或者对方场上1只怪兽解放，从手卡往那个控制者场上特殊召唤。
-- ②：这张卡被战斗破坏时，以对方场上1张卡为对象才能发动。那张卡破坏。
function c33331231.initial_effect(c)
	-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「闪刀姬」怪兽存在的场合，这张卡可以把自己场上1只怪兽解放，从手卡往那个控制者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33331231,0))  --"往自己场上特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,33331231+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c33331231.spcon)
	e1:SetTarget(c33331231.sptg)
	e1:SetOperation(c33331231.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「闪刀姬」怪兽存在的场合，这张卡可以把对方场上1只怪兽解放，从手卡往那个控制者场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33331231,1))  --"往对方场上特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP,1)
	e2:SetCountLimit(1,33331231+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c33331231.spcon2)
	e2:SetTarget(c33331231.sptg2)
	e2:SetOperation(c33331231.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗破坏时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33331231,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetTarget(c33331231.dstg)
	e3:SetOperation(c33331231.dsop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查怪兽是否为表侧表示的「闪刀姬」怪兽，用于确认自己场上是否存在表侧「闪刀姬」怪兽。
function c33331231.checkfilter(c)
	return c:IsSetCard(0x1115) and c:IsFaceup()
end
-- 候选解放怪兽的过滤：判断怪兽是否可作为这次特殊召唤的解放素材，且解放后目标玩家场上仍有可用怪兽区域来特殊召唤这张卡。
function c33331231.sprfilter(c,tp,sp)
	-- 怪兽必须能够被解放，并且解放后目标玩家场上仍有空余的怪兽区域，才能选为这次特殊召唤的解放素材。
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(tp,c,sp)>0
end
-- ①中解放自己场上怪兽来从手卡特殊召唤的规则手续的发动条件：自己场上有表侧「闪刀姬」怪兽，且自己场上有满足解放条件的怪兽可被解放。
function c33331231.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只表侧表示的「闪刀姬」怪兽。
	return Duel.IsExistingMatchingCard(c33331231.checkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在至少1只可被解放且解放后自己场上仍有可用怪兽区域的怪兽。
		and Duel.IsExistingMatchingCard(c33331231.sprfilter,tp,LOCATION_MZONE,0,1,nil,tp,tp)
end
-- ①中解放自己怪兽时的选择过程：从自己场上满足条件的怪兽中选择1只要解放的怪兽，并临时保存以便后续处理时解放。
function c33331231.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可以作为①特殊召唤解放素材的怪兽。
	local g=Duel.GetMatchingGroup(c33331231.sprfilter,tp,LOCATION_MZONE,0,nil,tp,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①特殊召唤的处理：将之前选择的怪兽解放，完成从手卡特殊召唤手续中的解放素材处理。
function c33331231.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放被选择的怪兽，作为这次特殊召唤手续的解放代价（REASON_SPSUMMON）。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①中解放对方场上怪兽来特殊召唤到对方场上的规则手续的发动条件：自己场上有表侧「闪刀姬」怪兽，且对方场上有满足解放条件的怪兽可被解放。
function c33331231.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只表侧表示的「闪刀姬」怪兽。
	return Duel.IsExistingMatchingCard(c33331231.checkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只可被解放且解放后对方场上仍有可用怪兽区域的怪兽。
		and Duel.IsExistingMatchingCard(c33331231.sprfilter,tp,0,LOCATION_MZONE,1,nil,1-tp,tp)
end
-- ①中解放对方怪兽时的选择过程：从对方场上满足条件的怪兽中选择1只要解放的怪兽，并临时保存以便后续处理时解放。
function c33331231.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有可以作为①特殊召唤解放素材的怪兽。
	local g=Duel.GetMatchingGroup(c33331231.sprfilter,tp,0,LOCATION_MZONE,nil,1-tp,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ②效果的发动条件和对象选择：这张卡被战斗破坏时，以对方场上1张卡为对象才能发动，发动后破坏那张卡。
function c33331231.dstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 发动时确认对方场上是否存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次连锁确定将破坏1张卡，用于星尘龙等多种效果的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得发动时选择的对象卡，若其仍与效果关联则将其破坏。
function c33331231.dsop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对方场上那张卡，作为本次破坏效果的处理对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
