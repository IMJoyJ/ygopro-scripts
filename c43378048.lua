--混沌幻魔アーミタイル
-- 效果：
-- 「神炎皇 乌利亚」＋「降雷皇 哈蒙」＋「幻魔皇 拉比艾尔」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡的攻击力在自己回合内上升10000。
-- ②：这张卡不会被战斗破坏。
function c43378048.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以神炎皇 乌利亚、降雷皇 哈蒙、幻魔皇 拉比艾尔为融合素材的通常融合召唤手续。
	aux.AddFusionProcCode3(c,6007213,32491822,69890967,true,true)
	-- 为这张卡注册接触融合手续：将自己场上可以作为除外代价的卡除外，并从额外卡组特殊召唤；对应‘把自己场上的上记卡除外的场合才能从额外卡组特殊召唤’。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 对应效果文本‘把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。’中从额外卡组特殊召唤的限制条件；此效果为不可无效、不可复制的原始效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c43378048.splimit)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力在自己回合内上升10000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c43378048.atkval)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制条件的判定函数：当这张卡当前不在额外卡组时允许特殊召唤；结合苏生限制，防止它被其他效果从额外卡组直接特殊召唤。
function c43378048.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 攻击力变化值的计算函数：根据当前回合是否为这张卡的控制者的回合来决定攻击力上升数值，自己回合上升10000，否则不上升。
function c43378048.atkval(e,c)
	-- 判断当前回合玩家是否等于这张卡的控制者；若成立则接下来返回攻击力上升值10000。
	if Duel.GetTurnPlayer()==e:GetHandlerPlayer() then
		return 10000
	else
		return 0
	end
end
