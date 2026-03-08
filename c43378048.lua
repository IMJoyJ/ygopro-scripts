--混沌幻魔アーミタイル
-- 效果：
-- 「神炎皇 乌利亚」＋「降雷皇 哈蒙」＋「幻魔皇 拉比艾尔」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡的攻击力在自己回合内上升10000。
-- ②：这张卡不会被战斗破坏。
function c43378048.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为6007213、32491822、69890967的3只怪兽为融合素材
	aux.AddFusionProcCode3(c,6007213,32491822,69890967,true,true)
	-- 添加接触融合特殊召唤规则，要求将自己场上的怪兽除外作为召唤代价
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- ①：这张卡的攻击力在自己回合内上升10000。
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
	-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c43378048.atkval)
	c:RegisterEffect(e3)
end
-- 限制该卡只能从额外卡组特殊召唤，不能通过其他方式特殊召唤
function c43378048.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 判断是否为当前回合玩家，是则攻击力上升10000，否则不变化
function c43378048.atkval(e,c)
	-- 判断是否为当前回合玩家
	if Duel.GetTurnPlayer()==e:GetHandlerPlayer() then
		return 10000
	else
		return 0
	end
end
