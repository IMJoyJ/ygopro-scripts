--アスポート
-- 效果：
-- ①：以自己的主要怪兽区域1只怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
function c37480144.initial_effect(c)
	-- ①：以自己的主要怪兽区域1只怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c37480144.target)
	e1:SetOperation(c37480144.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：选择位于自己主要怪兽区域（格子序号0~4）的怪兽，排除额外怪兽区。
function c37480144.filter(c)
	return c:GetSequence()<5
end
-- 对象合法性与发动条件判定：指定对象时必须是自己主要怪兽区域满足filter的怪兽；发动时需存在符合条件的对象怪兽且主要怪兽区域有空格。
function c37480144.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37480144.filter(chkc) end
	-- 发动条件判定：检查自己主要怪兽区域是否存在至少1只满足筛选条件且能成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c37480144.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件判定：同时确保自己主要怪兽区域有空余格子可供移动；两者均满足才可发动。
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 向操作玩家显示‘请选择要移动位置的怪兽’的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37480144,0))  --"请选择要移动位置的怪兽"
	-- 选择自己场上主要怪兽区域的1只怪兽作为效果对象，并注册为当前连锁的目标。
	Duel.SelectTarget(tp,c37480144.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数的前段：取得对象并进行合法性检查（对象仍关联本效果、仍由自己控制、有空格），若不满足则直接结束处理。
function c37480144.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		-- 若自己主要怪兽区域没有空余格子可移动，则效果处理失败并终止。
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<1 then return end
	-- 向操作玩家发出选择移动目标格子的提示信息（请选择要移动到的位置）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家在自己主要怪兽区域中选择1个可用的空格，返回该格子的位置标记。
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	-- 将对象怪兽移动到所选的目标格子（nseq为根据位置标记换算出的格子序号）。
	Duel.MoveSequence(tc,nseq)
end
