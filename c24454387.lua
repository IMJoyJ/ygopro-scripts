--ズットモザウルス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有其他的恐龙族怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
-- ②：以自己场上1张其他卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化效果注册：注册①效果，在自己场上有其他恐龙族怪兽存在时，此卡不能被对方怪兽选择为攻击对象；注册②效果，1回合1次以自己场上1张其他卡为对象才能发动，那张卡破坏。
function s.initial_effect(c)
	-- ①：只要自己场上有其他的恐龙族怪兽存在，对方怪兽不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.lacon)
	-- 设置①效果的Value为aux.imval1，即当攻击怪兽不免疫此效果时，不能选择这张卡作为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1张其他卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断一张卡是否为表侧表示且为恐龙族怪兽，用于检查场上是否存在其他恐龙族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- ①效果的生效条件：以效果持有者为视角，检查自己场上是否存在除自身以外的表侧恐龙族怪兽。
function s.lacon(e)
	local c=e:GetHandler()
	-- 检索自己场上（怪兽区）是否存在至少1张满足cfilter的卡（表侧恐龙族）且排除本卡。
	return Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,c)
end
-- ②效果的target函数：在发动时检查自己场上是否存在除这张卡以外的可对象卡，若存在则让玩家选择1张，并设置破坏该卡的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	-- 在效果发动时（chk==0）检查自己场上是否存在除这张卡以外的可选对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c) end
	-- 向发动玩家显示选择要破坏的卡的提示信息（HINTMSG_DESTROY）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张除这张卡以外的卡作为效果对象（同时登记为当前连锁的对象）。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置当前连锁的操作信息：将对象卡g记为将被破坏的卡，类别为CATEGORY_DESTROY，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理函数：取得对象卡，若对象仍与效果关联，则将其破坏；否则不处理。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时的第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡与效果e仍有关联（未因离场等重置联系），则将其以效果（REASON_EFFECT）破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
