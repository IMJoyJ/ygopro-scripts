--宣告者の神託
-- 效果：
-- 「崇光之宣告者」的降临必需。对方不能对应这张卡的发动把魔法·陷阱·怪兽的效果发动。
-- ①：从自己的手卡·场上把等级合计直到12以上的怪兽解放，从手卡把「崇光之宣告者」仪式召唤。
function c79306385.initial_effect(c)
	-- 为卡片注册仪式召唤「崇光之宣告者」的效果，素材等级合计需在12以上，并指定额外效果处理函数
	aux.AddRitualProcGreaterCode(c,48546368,nil,nil,nil,false,nil,c79306385.extratg)
end
-- 定义额外效果处理函数，在魔法卡发动时设置连锁限制
function c79306385.extratg(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，限制对方玩家对应此卡的发动进行连锁
		Duel.SetChainLimit(c79306385.chlimit)
	end
end
-- 定义连锁限制的具体规则，即只有发动该效果的玩家自身可以进行连锁
function c79306385.chlimit(e,ep,tp)
	return tp==ep
end
