--トランスファミリア
-- 效果：
-- ①：1回合1次，以自己场上1只怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
function c7969770.initial_effect(c)
	-- ①：1回合1次，以自己场上1只怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7969770,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c7969770.mvtg)
	e1:SetOperation(c7969770.mvop)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件和可选择的对象：对象必须是自己场上的怪兽，且自己场上必须有空余的主要怪兽区域
function c7969770.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 发动条件及对象检查：自己场上存在至少1只可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 且自己的主要怪兽区域有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 提示玩家选择作为对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(7969770,1))  --"请选择要移动到的位置"
	-- 选择自己场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取对象怪兽，并确认其仍与效果相关、控制权未改变且自己场上仍有空余的主要怪兽区域
function c7969770.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		-- 若此时自己的主要怪兽区域没有空位，则不处理效果
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择1个自己场上可用的主要怪兽区域
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	-- 将对象怪兽移动到选定的主要怪兽区域
	Duel.MoveSequence(tc,nseq)
end
