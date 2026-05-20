--キメラテック・フォートレス・ドラゴン
-- 效果：
-- 「电子龙」＋机械族怪兽1只以上
-- 把自己·对方场上的上记的卡送去墓地的场合才能从额外卡组特殊召唤。这张卡不能作为融合素材。
-- ①：这张卡的原本攻击力变成作为这张卡的融合素材的怪兽数量×1000。
function c79229522.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合素材手续：1只「电子龙」和1只以上的机械族怪兽
	aux.AddFusionProcCodeFunRep(c,70095154,c79229522.mfilter,1,127,true,true)
	-- 添加接触融合的特殊召唤规则，素材来源于双方场上，并执行送去墓地及改变攻击力的操作
	aux.AddContactFusionProcedure(c,c79229522.cfilter,LOCATION_ONFIELD,LOCATION_ONFIELD,c79229522.sprop(c))
	-- 把自己·对方场上的上记的卡送去墓地的场合才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c79229522.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不能作为融合素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
c79229522.material_setcode=0x1093
-- 限制该卡从额外卡组特殊召唤时，只能通过其自身规则（接触融合）进行特殊召唤
function c79229522.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 融合素材过滤：判定是否为机械族怪兽
function c79229522.mfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
end
-- 接触融合素材过滤：判定是否可以作为代价值送去墓地，且必须是自己场上的卡或对方场上表侧表示的卡
function c79229522.cfilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- 定义接触融合的特殊召唤手续：将素材送去墓地，并根据送去墓地的素材数量设置该卡的原本攻击力
function c79229522.sprop(c)
	return	function(g)
				-- 将选定的融合素材作为特殊召唤的代价值送去墓地
				Duel.SendtoGrave(g,REASON_COST)
				local ct=g:GetCount()
				-- ①：这张卡的原本攻击力变成作为这张卡的融合素材的怪兽数量×1000。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
				e1:SetReset(RESET_EVENT+0xff0000)
				e1:SetValue(ct*1000)
				c:RegisterEffect(e1)
			end
end
